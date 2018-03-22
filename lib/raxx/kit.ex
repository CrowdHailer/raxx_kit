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
      IO.inspect(assigns)

      :ok = template_dir()
      |> Path.join("./**/*")
      |> Path.wildcard(match_dot: true)
      |> Enum.each(&copy_template(&1, template_dir(), assigns))

      Mix.shell.cmd("mix deps.get")
    end)
    message = """
    Your Raxx project was created successfully.

    Get started:

        cd #{config.name}
        #{if config.docker, do: "docker-compose up", else: "iex -S mix"}

    View on http://localhost:8080
    View on https://localhost:8443 (NOTE: uses a self signed certificate)
    """
    |> String.trim_trailing
    {:ok, message}
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
        {path, contents} = case String.split(path, ~r/\.eex$/) do
          [path, ""] ->
            path = String.replace(path, "app_name", assigns.name)
            contents = EEx.eval_string(template, [assigns: assigns])
            {path, contents}
          [path] ->
            path = String.replace(path, "app_name", assigns.name)
            contents = template
            {path, contents}
        end
        if String.trim(contents) == "" do
          :ok
        else
          Mix.Generator.create_file(path, contents)
        end
    end
  end
end
