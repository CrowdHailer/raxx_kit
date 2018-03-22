defmodule Mix.Tasks.Raxx.Kit do
  use Mix.Task

  require Mix.Generator

  @shortdoc "Create a new Raxx project for browsers"
  @switches [docker: :boolean, apib: :boolean, module: :string, node_assets: :boolean]

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
