defmodule Tokumei do
  defmacro __using__(_opts) do
    quote do
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

    defmacro config(:port, port) do
      quote do
        @port unquote(port)
      end
    end
  end

end
