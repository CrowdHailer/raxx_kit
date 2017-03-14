defmodule Mix.Tasks.Tokumei.Routes do
  use Mix.Task
  @shortdoc "Shiny new Tokumei application. :-)"
  @moduledoc """
  ```
  mix tokumei.new <app_dir>
  ```
  """

  def run([module]) do
    IO.inspect(module)
  end
end
