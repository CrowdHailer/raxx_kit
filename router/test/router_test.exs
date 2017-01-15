defmodule Tokumei.RouterTest do
  use ExUnit.Case
  alias Raxx.Request
  alias Raxx.Response

  import Tokumei.Router

  route "foo" do
    :GET -> Response.ok("foo")
    :POST -> Response.no_content()
  end

  test "Will match on a single path element" do
    %{status: status, body: body} = get("/foo")
    assert 200 == status
    assert "foo" == body
  end

  test "Will match on any method single path element" do
    %{status: status, body: body} = post("/foo")
    assert 204 == status
  end

  route "bar" do
    :GET ->
      IO.inspect(request)
      Response.ok()
  end

  test "Will handle multiple lines single path element" do
    assert 200 == get("/bar").status
  end

  defp get(path) do
    Request.get(path)
    |>  __MODULE__.handle_request(:empty_env)
  end

  defp post(path) do
    Request.post(path)
    |>  __MODULE__.handle_request(:empty_env)
  end
end
