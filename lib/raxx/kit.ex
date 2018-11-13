defmodule Raxx.Kit do
  @enforce_keys [
    :name,
    :module,
    :docker,
    :api_blueprint,
    :node_assets
  ]

  defstruct @enforce_keys

  def generate(options) do
    # TODO check if dir exists
    config = check_config!(options)

    :ok = Mix.Generator.create_directory(config.name)

    File.cd!(config.name, fn ->
      assigns = Map.from_struct(config)

      :ok =
        template_dir()
        |> Path.join("./**/*")
        |> Path.wildcard()
        |> Enum.each(&copy_template(&1, template_dir(), assigns))

      # If using docker elixir and mix might not be installed so this should be run in docker
      if !config.docker do
        Mix.shell().cmd("mix deps.get")
        Mix.shell().cmd("mix format")
      end
    end)

    # If using docker node might not be installed so this should be run in docker
    if !config.docker && config.node_assets do
      File.cd!(config.name <> "/lib/" <> config.name <> "/www", fn ->
        Mix.shell().cmd("nodejs -v")
        Mix.shell().cmd("npm install")
      end)
    end

    message =
      """
      Your Raxx project was created successfully.

      Get started:

          cd #{config.name}
          #{if config.docker, do: "docker-compose up", else: "iex -S mix"}

      View on http://localhost:8080
      View on https://localhost:8443 (NOTE: uses a self signed certificate)
      """
      |> String.trim_trailing()

    {:ok, message}
  end

  defp check_config!(options) do
    {:ok, name} = Keyword.fetch(options, :name)
    module = Keyword.get(options, :module, Macro.camelize(name))
    docker = Keyword.get(options, :docker, false)
    node_assets = Keyword.get(options, :node_assets, false)
    api_blueprint = Keyword.get(options, :apib, false)

    %__MODULE__{
      name: name,
      module: module,
      docker: docker,
      api_blueprint: api_blueprint,
      node_assets: node_assets
    }
  end

  defp template_dir() do
    Application.app_dir(:raxx_kit, "priv/template")
  end

  defp copy_template(file, root, assigns) do
    case File.read(file) do
      {:error, :eisdir} ->
        path = Path.relative_to(file, root)
        Mix.Generator.create_directory(path)

      {:ok, template} ->
        path = Path.relative_to(file, root)

        {path, contents} =
          case String.split(path, ~r/\.eex$/) do
            [path, ""] ->
              path =
                String.replace(path, "app_name", assigns.name)
                |> String.replace("_DOTFILE", "")

              contents = EEx.eval_string(template, assigns: assigns)
              {path, contents}

            [path] ->
              path =
                String.replace(path, "app_name", assigns.name)
                |> String.replace("_DOTFILE", "")

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
