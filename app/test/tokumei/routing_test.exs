defmodule Tokumei.RoutingTest do

  use ExUnit.Case
  alias Raxx.Request

  use Tokumei.Routing
  import Raxx.Response
  import Raxx.Request

  @route_name :foo
  route "/foo", {_, _, _} do
    :GET ->
      ok("get")
    :POST ->
      ok("post")
  end

  test "matches on a single path element" do
    response = get("/foo") |> handle_request(:config)
    assert 200 = response.status
    assert "get" = response.body
  end

  test "matches correct method on single path element" do
    response = post("/foo") |> handle_request(:config)
    assert 200 = response.status
    assert "post" = response.body
  end

  test "can generate path" do
    # assert "/foo" == path(:foo)
  end

  test "route is added to the list of routes, with name" do
    routes
    |> IO.inspect
    assert Enum.member?(routes, {:foo, "/foo", [:GET, :POST]})
  end

  test "will return method not allowed for un implemented methods" do
    response = delete("/foo") |> handle_request(:config)
    assert 405 = response.status
    assert "Method not allowed" = response.body
  end

  test "will return not found for unimplemented route" do
    {:error, exception} = get("/random") |> handle_request(:config)
    assert ["random"] = exception.path
  end

  route "/variables/:a/:b/:c/", {_r, _c, %{a: x, b: y, c: z}} do
    :GET ->
      # IO.inspect(params)
      ok({x, y, z})
  end

  test "assign path variables to provided variables" do
    response = get("/variables/a1/b2/c3") |> handle_request(:x)
    assert {"a1", "b2", "c3"} == response.body
  end

  route "/config", {_request, config, params} do
    :GET ->
      ok(config)
  end

  test "will access provided config" do
    response = get("/config") |> handle_request("some config")
    assert "some config" == response.body
  end
end
