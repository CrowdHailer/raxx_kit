defmodule Tokumei.Templates do
  @moduledoc """
  Generate render functions for a directory of templates.

  ```elixir
  defmodule TemplatesExample do
    use Tokumei.Templates, "./templates"
  end
  ```

  Rendering a template will return a partial response with mime type set.
  This can be passed directly to response functions

  ```elixir
    Raxx.Response.ok("example.html", content: "Hi!")
  ```

  Templates have:

  - A name: filename without eex extension
  - A mime type: derived from the file extension
  """

  @doc false
  def comprehend_path(file_path) do
    file_path
    |> String.split("/")
    |> List.last()
    |> String.split(".")
    |> case do
      [filename, extension, "eex"] ->
        {filename <> "." <> extension, MIME.type(extension)}
    end
  end

  defmacro __using__(opts) do
    root = Keyword.get(opts, :at, "./templates")

    quote do
      require Tokumei.Path
      require EEx
      dir = Tokumei.Path.to(unquote(root))
      @external_resource unquote(root)
      Module.eval_quoted(__MODULE__, quote do
        def render(name, assigns)
      end)

      file_paths = Path.expand("./*.eex", dir) |> Path.wildcard
      for file_path <- file_paths do
        case Tokumei.Templates.comprehend_path(file_path) do
          {name, mime} ->
            content_function_name = String.to_atom(name <> "_content")
            EEx.function_from_file :defp, content_function_name, file_path, [:assigns]
            ast = quote do
              def render(unquote(name), assigns) do
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
  end
end
