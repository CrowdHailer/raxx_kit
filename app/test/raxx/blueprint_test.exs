defmodule Raxx.BlueprintTest do
  alias Raxx.Blueprint

  use ExUnit.Case

  """

  """

  test "1" do
    blueprint = """
    FORMAT: 1A

    # An Example API

    # My Message [/messages]
    ## Create One [POST]
    """
    assert [{"/messages", [POST: :CreateOne]}] == Blueprint.parse(blueprint)
  end
end
