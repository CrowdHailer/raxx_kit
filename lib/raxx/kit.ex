defmodule Raxx.Kit do
  @enforce_keys [
    :name,
    :module,
    :docker,
    :api_blueprint,
    :node_assets,
    :exsync,
    :ecto
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

      if config.docker do
        # Getting npm and mix dependencies is handled in start.sh/Dockerfile
        Mix.shell().cmd("docker-compose run #{config.name} mix format")
      else
        # If using Docker mix/node/npm might not be available on host machine
        Mix.shell().cmd("mix deps.get")
        Mix.shell().cmd("mix format")

        if config.node_assets do
          File.cd!("lib/" <> config.name <> "/www", fn ->
            Mix.shell().cmd("npm install")
          end)
        end
      end
    end)

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
    exsync = !Keyword.get(options, :no_exsync, false)
    ecto = Keyword.get(options, :ecto, false)

    %__MODULE__{
      name: name,
      module: module,
      docker: docker,
      api_blueprint: api_blueprint,
      node_assets: node_assets,
      exsync: exsync,
      ecto: ecto
    }
  end

  defp template_dir() do
    Application.app_dir(:raxx_kit, "priv/template")
  end

  defp copy_template(file, root, assigns) do
    case File.read(file) do
      {:error, :eisdir} ->
        path =
          Path.relative_to(file, root)
          |> translate_path(assigns)

        Mix.Generator.create_directory(path)

      {:ok, template} ->
        original_path = Path.relative_to(file, root)

        {path, contents} =
          case String.split(original_path, ~r/\.eex$/) do
            [path, ""] ->
              path = translate_path(path, assigns)
              contents =
                try do
                  EEx.eval_string(template, assigns: assigns)
                rescue
                  e in EEx.SyntaxError ->
                    Mix.shell().error("Generator could not evaluate template under path '#{original_path}'")
                    reraise e, __STACKTRACE__
                end
              {path, contents}

            [path] ->
              path = translate_path(path, assigns)
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

  defp translate_path(path, assigns) do
    path
    |> String.replace("app_name", assigns.name, global: true)
    |> String.replace("_DOTFILE", "")
  end
end
