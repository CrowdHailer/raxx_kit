defmodule ExampleTest do
  use ExUnit.Case

  test "Get home page" do
    response = Raxx.Request.get("/")
    |> Example.handle_request(:state)
    assert 200 == response.status
  end

  test "" do

  end
end
