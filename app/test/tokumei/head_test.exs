defmodule Tokumei.HeadTest do
  use ExUnit.Case

  alias Raxx.Request
  alias Raxx.Response

  use Tokumei.Head

  def handle_request(%{method: :GET}, _), do: Response.ok("GET")
  def handle_request(%{method: :POST}, _), do: Response.ok("POST")

  test "head request returns get request without content" do
    response = Request.head("/") |> handle_request(:config)
    assert 200 == response.status
    assert "" == response.body
  end

  test "GET requests are unmodified" do
    response = Request.get("/") |> handle_request(:config)
    assert 200 == response.status
    assert "GET" == response.body
  end

  test "POST requests are unmodified" do
    response = Request.post("/") |> handle_request(:config)
    assert 200 == response.status
    assert "POST" == response.body
  end
end
