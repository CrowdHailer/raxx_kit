defmodule Tokumei.RoutingTest do
  use ExUnit.Case
  alias Raxx.Request

  use Tokumei.Routing
  import Raxx.Response

  @route_name :foo
  @allowed [:GET, :POST]
  route "/foo" do
    _a = get(_request) ->
      ok("get")
    post(_request) ->
      ok("post")
  end

  test "matches on a single path element" do
    response = Request.get("/foo") |> handle_request()
    assert 200 = response.status
    assert "get" = response.body
  end

  test "matches correct method on single path element" do
    response = Request.post("/foo") |> handle_request()
    assert 200 = response.status
    assert "post" = response.body
  end

  test "route is added to the list of routes, with name" do
    assert Enum.member?(routes, {:foo, "/foo", [:GET, :POST]})
  end

  test "will return method not allowed for un implemented methods" do
    response = Request.delete("/foo") |> handle_request()
    assert 405 = response.status
    assert "Method not allowed" = response.body
  end

  test "will return not found for unimplemented route" do
    {:error, exception} = Request.get("/random") |> handle_request()
    assert ["random"] = exception.path
  end

  route "/variables/:a/:b/:c/", {x, y, z} do
    get(_request) ->
      ok({x, y, z})
  end

  test "assign path variables to provided variables" do
    response = Request.get("/variables/a1/b2/c3") |> handle_request()
    assert {"a1", "b2", "c3"} == response.body
  end

  route "/config" do
    get(_, config) ->
      ok(config)
  end

  test "will access provided config" do
    response = Request.get("/config") |> handle_request("some config")
    assert "some config" == response.body
  end
end
