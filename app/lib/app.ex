defmodule Tokumei do
  defmacro __using__(_opts) do
    quote do
      require Raxx.Static
      alias Tokumei.ServerSentEvents, as: SSE
      require SSE
      import Tokumei.Helpers
      import Raxx.Response
      use Tokumei.Routing
      @before_compile Tokumei

      def redirect(path) do
        Raxx.Response.found([{"location", path}])
      end
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
                def unquote(file_name |> String.to_atom)(assigns \\ %{}) do
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
