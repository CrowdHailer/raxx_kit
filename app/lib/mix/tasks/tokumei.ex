defmodule Mix.Tasks.Tokumei.New do
  use Mix.Task
  @shortdoc "Shiny new Tokumei application. :-)"
  @moduledoc """
  ```
  mix tokumei.new <app_dir>
  ```
  """

  def run([]) do
    Mix.Tasks.Help.run ["tokumei.new"]
  end

  @safe_app_name ~r/^[a-z][\w_]*$/
  def run([project_path]) do
    app_name = project_path
    app_name =~ @safe_app_name
    app_module = Macro.camelize(app_name)
    # if Mix.shell.yes?("continue?") do
    if true do
      File.mkdir_p!(project_path)
      File.cd!(project_path, fn() ->
        generate(app_name, app_module, [app_name: app_name, app_module: app_module])
      end)
      """
      Your Tokumei project was created successfully.

      Get started:

          cd #{project_path}
          mix deps.get
          iex -S mix

      View on localhost:8080
      """
      |> String.trim_trailing
      |> Mix.shell.info
    end
  end

  defp generate(app_name, app_module, bindings) do
    this_dir = Path.dirname(__ENV__.file)
    template_files = Path.expand("./**/*", this_dir) |> Path.wildcard(match_dot: true)
    for template_file <- template_files do
      case String.split(template_file, ~r/\.eex$/) do
        [file_name, ""] ->
          path = Path.relative_to(file_name, Path.expand("./template", this_dir))
          case File.read(template_file) do
            {:ok, template} ->
              path = String.replace(path, "app_name", app_name)
              File.mkdir_p!(Path.dirname(path))
              contents = EEx.eval_string(template, bindings)
              File.write!(path, contents)
            {:error, :eisdir} ->
              :nope
          end
        [file_name] ->
          path = Path.relative_to(file_name, Path.expand("./template", this_dir))
          case File.read(template_file) do
            {:ok, contents} ->
              path = String.replace(path, "app_name", app_name)
              File.mkdir_p!(Path.dirname(path))
              File.write!(path, contents)
            {:error, :eisdir} ->
              :nope
          end
      end
    end
  end
end
