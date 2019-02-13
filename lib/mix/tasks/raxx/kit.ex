defmodule Mix.Tasks.Raxx.Kit do
  use Mix.Task

  @impl Mix.Task
  def run(_arguments) do
    Mix.shell().error("Task `raxx.kit` has been deprecated; use `raxx.new`.")
  end
end
