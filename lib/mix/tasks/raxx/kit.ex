defmodule Mix.Tasks.Raxx.Kit do
  use Mix.Task

  require Mix.Generator

  @shortdoc "Creates a new Raxx project for browsers"
  @switches [
    docker: :boolean,
    apib: :boolean,
    module: :string,
    node_assets: :boolean,
    no_exsync: :boolean
  ]

  @moduledoc """
  Creates a new Raxx project for browsers.

  It expects the name of the project as the argument.

      mix raxx.kit NAME [--node-assets] [--docker] [--module ModuleName] [--apib]

  ## Options

  - `--node-assets`: Add JavaScript compilation as part of a generated project.
    Works with or without docker.

  - `--docker`: Create `Dockerfile` and `docker-compose.yml` in template.
    This allows local development to be conducted completly in docker.

  - `--module`: Used to name the top level module used in the generated project.
    Without this option the module name will be generated from path option.

  - `--no-exsync`: Doesn't include exsync in the generated project. Changed
    files won't be rebuilt on the fly when the app is running.

  ```sh
  $ mix raxx.kit my_app

  # Is equivalent to
  $ mix raxx.kit my_app --module MyApp
  ```

  - `--apib`: Generate an API Blueprint file which is used as the project router.

  """

  @impl Mix.Task
  def run([]) do
    Mix.Tasks.Help.run(["raxx.kit"])
  end

  def run(options) do
    case OptionParser.parse!(options, strict: @switches) do
      {_, []} ->
        Mix.raise("raxx.kit must be given a name `mix raxx.kit <name>`")

      {switches, [name]} ->
        {:ok, message} = Raxx.Kit.generate([{:name, name} | switches])

        Mix.shell().info(message)
    end
  end
end
