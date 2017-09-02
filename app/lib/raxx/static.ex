defmodule Raxx.Static do
  @moduledoc """
  To see how to use this module check the tests.
  The API is still in development as we handle some updates

      defmodule StaticFileServer do
        require Raxx.Static

        # relative path to assets directory
        dir = "./static"
        Raxx.Static.serve_dir(dir)
      end

  other things this should do are:
  - send a response for a HEAD request
  - return a method not allowed for other HTTP methods
  - return content error from accept headers
  - gzip encoding
    plug doesnt actually gzip it just assumes a file named path <>.gz
    gzip is assumed false by default, say true to generate gz from contents or path modification if zipped exists.
    https://groups.google.com/forum/#!topic/elixir-lang-talk/RL-qWWx9ILE
  - have an overwritable not_found function
  - cache control time
  - Etags
  - filtered reading of a file
  - set a maximum size of file to bundle into the code.
  - static_content(content, mime)
  - check trying to serve root file
  - use plug semantics of {:app, path/in/priv} or "/binary/absoulte" or "./binary/from/file"
  """
  defmacro __using__(path = "./" <> _) do
    quote do
      use unquote(__MODULE__), root: unquote(path)
    end
  end
  defmacro __using__(opts) do
    dir = Keyword.get(opts, :root, "./public")
    quote do
      require Raxx.Static

      @static unquote(dir)

      @before_compile unquote(__MODULE__)
    end
  end

  defmacro __before_compile__(_env) do
    quote do
      defoverridable [handle_headers: 2]

      @external_resource @static
      Raxx.Static.serve_dir(@static)

      def handle_headers(request, config) do
        super(request, config)
      end
    end
  end

  defmacro serve_file(filename, path) do
    quote do
      ast = unquote(__MODULE__).serve_file_ast(unquote(filename), unquote(path))
      Module.eval_quoted(__MODULE__, ast)
    end
  end

  @doc false
  def serve_file_ast(filename, path) do
    request_match = quote do: %{path: unquote(path)}
    mime = MIME.from_path(filename)
    # Should make use of Response.ok({file: filename})
    case File.read(filename) do
      {:ok, content} ->
        response = Raxx.response(:ok)
        |> Raxx.set_header("content-length", "#{:erlang.iolist_size(content)}")
        |> Raxx.set_header("content-type", mime)
        |> Raxx.set_body(content)
        quote do
          def handle_headers(request = unquote(request_match), _) do
            case request.method do
              :GET ->
                unquote(Macro.escape(response))
              _ ->
                Raxx.response(:method_not_allowed)
            end
          end
        end
      {:error, :eisdir} ->
        nil
    end
  end

  defmacro serve_dir(dir) do
    quote do
      dir = Path.expand(unquote(dir), Path.dirname(__ENV__.file))
      filenames = Path.expand("./**/*", dir) |> Path.wildcard
      # Make use of File.stat instead of just reading.
      for filename <- filenames do
        relative = Path.relative_to(filename, dir)
        path = Path.split(relative)
        Raxx.Static.serve_file(filename, path)
      end
    end
  end
end
