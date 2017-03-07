defmodule Tokumei.Templates do
  defmacro __using__(_opts) do
    quote do
      require EEx
      @templates "./templates"
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
    end
  end
end
