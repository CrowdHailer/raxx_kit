defmodule Tokumei do
  defmacro __using__(_opts) do
    quote do
      require Raxx.Static
      @before_compile Tokumei
    end
  end
  defmacro __before_compile__(_opts) do
    quote do
      use Application
      def start(_type, _args) do
        import Supervisor.Spec, warn: false

        port = @port || 8080
        true = Code.ensure_loaded?(Ace.HTTP)
        children = [
          worker(Ace.HTTP, [{__MODULE__, []}, [port: port, name: __MODULE__]])
        ]

        opts = [strategy: :one_for_one, name: Tokumei.Supervisor]
        Supervisor.start_link(children, opts)
      end

      if @static do
        @external_resource @static
        Raxx.Static.serve_dir(@static)
      end

      require EEx

      if @templates do
        @external_resource @templates
        dir = Path.expand(@templates, Path.dirname(__ENV__.file))
        file_paths = Path.expand("./**/*.eex", dir) |> Path.wildcard
        for file_path <- file_paths do
          file_path
          |> String.split("/")
          |> List.last()
          |> String.split(".")
          |> case do
            [file_name, extension, "eex"] ->
              content_function_name = String.to_atom(file_name <> "_content")
              EEx.function_from_file :defp, content_function_name, file_path, [:assigns]
              mime = MIME.type(extension)
              ast = quote do
                def unquote(file_name |> String.to_atom)(assigns) do
                  %{
                    body: unquote(content_function_name)(assigns),
                    headers: [{"content-type", unquote(mime)}]
                  }
                end
              end
              Module.eval_quoted(__MODULE__, ast)
          end
        end
      end

      defoverridable [handle_request: 2]

      def handle_request(request, env) do
        response = super(request, env)
        case response do
          %{body: _} -> # I am a response
            response = case Raxx.ContentLength.fetch(response) do
              {:ok, _} ->
                response
              {:error, :field_value_not_specified} ->
                Raxx.ContentLength.set(response, :erlang.iolist_size(response.body))
            end
          upgrade = %Raxx.Chunked{} ->
            upgrade
        end

      end
    end
  end

  defmodule Helpers do
    defp build_match(segments, vars, reversed \\ [])
    defp build_match([], [], reversed) do
      Enum.reverse(reversed)
    end
    defp build_match([":" <> _| segments], [var | vars], reversed) do
      reversed = [var | reversed]
      build_match(segments, vars, reversed)
    end
    defp build_match([segment| segments], vars, reversed) do
      reversed = [segment | reversed]
      build_match(segments, vars, reversed)
    end
    defmacro route(path, {:{}, _, vars}, do: clauses) do
      path = build_match(Raxx.Request.split_path(path), vars)
      request_match = quote do: %{path: unquote(path)}
      quote do
        def handle_request(request = unquote(request_match), env) do
          case {request.method, request, env} do
            unquote(clauses)
          end
        end
      end
    end
    defmacro route(path, do: clauses) when is_list(path) do
      request_match = quote do: %{path: unquote(path)}
      clauses = clauses ++ (quote do
        request -> {:error, :not_allowed}
      end)
      quote do
        def handle_request(request = unquote(request_match), env) do
          case {request.method, request, env} do
            unquote(clauses)
          end
        end
      end
    end
    defmacro route(path, do: clauses) do
      path = Raxx.Request.split_path(path)
      request_match = quote do: %{path: unquote(path)}
      clauses = clauses ++ (quote do
        request -> {:error, :not_allowed}
      end)
      quote do
        def handle_request(request = unquote(request_match), env) do
          case {request.method, request, env} do
            unquote(clauses)
          end
        end
      end
    end

    defmacro get(request, env) do
      quote do: {:GET, unquote(request), unquote(env)}
    end
    defmacro get(request) do
      quote do: {:GET, unquote(request), _}
    end
    defmacro get() do
      quote do: {:GET, _, _}
    end
    defmacro post(request, env) do
      quote do: {:POST, unquote(request), unquote(env)}
    end
    defmacro post(request) do
      quote do: {:POST, unquote(request), _}
    end
    defmacro post() do
      quote do: {:POST, _, _}
    end

    defmacro config(:port, port) do
      quote do
        @port unquote(port)
      end
    end
    defmacro config(:static, port) do
      quote do
        @static unquote(port)
      end
    end
    defmacro config(:templates, port) do
      quote do
        @templates unquote(port)
      end
    end
  end

end
