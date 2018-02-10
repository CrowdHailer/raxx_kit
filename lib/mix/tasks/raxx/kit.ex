defmodule Mix.Tasks.Raxx.Kit do
  use Mix.Task

  require Mix.Generator

  @shortdoc "Create a new Raxx project for browsers"
  @switches [docker: :boolean, "apib": :boolean, module: :string]

  @impl Mix.Task
  def run([]) do
    Mix.Tasks.Help.run ["raxx.kit"]
  end
  def run(options) do
    case OptionParser.parse!(options, strict: @switches) do
      {_, []} ->
        Mix.raise("raxx.kit must be given a name `mix raxx.kit <name>`")
      {switches, [name]} ->
        Raxx.Kit.generate([{:name, name} | switches])
        """
        Your project was created successfully.

        Get started:

        cd #{name}
        docker-compose up

        View on https://localhost:8443
        """
        |> String.trim_trailing
        |> Mix.shell.info
    end
  end
end
