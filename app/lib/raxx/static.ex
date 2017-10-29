defmodule Raxx.Static do
  @moduledoc """
  Serve the contents of a directory as static content.

      defmodule MyApp do
        use Raxx.Server
        use Raxx.Router, [
          {%{method: :GET, path: []}, MyApp.HomePage}
        ]
        use Raxx.Static, "./public"
      end

  *If the path given to `Raxx.Static` is relative,
  it will be expanded relative to the file using `Raxx.Static`

  Using `Raxx.Static` writes a route for each file in the given directory.
  If a request does not match any of these paths it will be passed up the stack.
  In this example if a request does not match content in the public dir it will then be passed to the router

  #### Extensions

  Proposed extensions to Raxx.Static:

  - Check accept header and return content error when appropriate
  - gzip encoding
    plug doesnt actually gzip it just assumes a file named path <>.gz
    gzip is assumed false by default, say true to generate gz from contents or path modification if zipped exists.
    https://groups.google.com/forum/#!topic/elixir-lang-talk/RL-qWWx9ILE
  - cache control time
  - Etags
  - filtered reading of a file
  - set a maximum size of file to bundle into the code.
  - static_content(content, mime)
  - check trying to serve root file
  - use plug semantics of {:app, path/in/priv} or "/binary/absoulte" or "./binary/from/file"
  """
  defmacro __using__(static_dir) do
    # Expand whatever the user has done to their path
    {static_dir, []} = Module.eval_quoted(__CALLER__, static_dir)
    # If a relative path is given expand in relation to the callers file
    static_dir = Path.expand(static_dir, Path.dirname(__CALLER__.file))
    pattern = "./**/*.*"
    filepaths = Path.wildcard(Path.expand(pattern, static_dir))

    actions = Enum.flat_map(filepaths, fn
      (filepath) ->
        case File.read(filepath) do
          {:ok, content} ->
            mime = MIME.from_path(filepath)
            route = Path.relative_to(filepath, static_dir) |> Path.split
            response = Raxx.response(:ok)
            |> Raxx.set_header("content-length", "#{:erlang.iolist_size(content)}")
            |> Raxx.set_header("content-type", mime)
            |> Raxx.set_body(content)
            [{route, response}]
          {:error, :eisdir} ->
            []
        end
    end)
    routes_ast = for {route, response} <- actions do
      quote do
        def handle_head(%{method: :GET, path: unquote(route)}, _) do
          unquote(Macro.escape(response))
        end
      end
    end

    quote do
      @impl Raxx.Server
      unquote(routes_ast)
      def handle_head(request, config) do
        super(request, config)
      end

      defoverridable [handle_head: 2]
    end
  end
end
