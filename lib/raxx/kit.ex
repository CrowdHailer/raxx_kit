defmodule Raxx.Kit do
  @enforce_keys [
    :name,
    :module,
    :docker,
    :api_blueprint
  ]

  defstruct @enforce_keys

  def generate(options) do
    # TODO check if dir exists
    config = check_config!(options)

    :ok = Mix.Generator.create_directory(config.name)
    File.cd!(config.name, fn() ->
      assigns = Map.from_struct(config)

      :ok = template_dir()
      |> Path.join("./**/*")
      |> Path.wildcard(match_dot: true)
      |> Enum.each(&copy_template(&1, template_dir(), assigns))

      Mix.shell.cmd("mix deps.get")
    end)
  end

  defp check_config!(options) do
    {:ok, name} = Keyword.fetch(options, :name)
    module = Keyword.get(options, :module, Macro.camelize(name))
    docker = Keyword.get(options, :docker, false)
    api_blueprint = Keyword.get(options, :apib, false)

    %__MODULE__{
      name: name,
      module: module,
      docker: docker,
      api_blueprint: api_blueprint
    }
  end

  defp template_dir() do
    Application.app_dir(:raxx_kit, "priv/template")
  end

  defp copy_template(file, root, assigns) do
    case File.read(file) do
      {:error, :eisdir} ->
        Mix.Generator.create_directory(file)
      {:ok, template} ->
        path = Path.relative_to(file, root)
        case String.split(path, ~r/\.eex$/) do
          [path, ""] ->
            path = String.replace(path, "app_name", assigns.name)
            Mix.Generator.create_file(path, EEx.eval_string(template, [assigns: assigns]))
          [path] ->
            path = String.replace(path, "app_name", assigns.name)
            Mix.Generator.create_file(path, template)
        end
    end
  end
end
