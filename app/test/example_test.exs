defmodule ExampleTest do
  use ExUnit.Case

  test "Get home page" do
    response = Raxx.Request.get("/")
    |> Example.handle_request(:state)
    assert 200 == response.status
    # TODO wrapper that gets config from config files
  end

  test "fetch static content" do
    response = Raxx.Request.get("/favicon.ico")
    |> Example.handle_request(:state)
    assert 200 == response.status
    IO.inspect(response.headers)
  end
end
