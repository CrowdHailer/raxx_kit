defmodule Mix.Tasks.Tokumei do
  use Mix.Task
  @shortdoc "The task that will set up tokumei"

  def run(args) do
    IO.inspect(args)
    IO.puts("Example task")
  end
end
