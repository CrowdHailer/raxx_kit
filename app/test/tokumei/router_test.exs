defmodule Tokumei.RouterTest do
  use ExUnit.Case
  use Tokumei.Router
  alias Raxx.Request

  ## Fixed path routing

  @route_name :users
  route ["users"] do
    :GET ->
      :get_users
    :POST ->
      :post_users
    method ->
      {:error, {:not_allowed, method, [:GET, :POST]}}
  end

  test "matches on a fixed path segments" do
    assert :get_users = Request.get("/users") |> handle_request(:config)
  end

  test "matches on correct request method" do
    assert :post_users = Request.post("/users") |> handle_request(:config)
  end

  test "return error, with allowed methods, when calling unhandled method" do
    assert {:error, {:not_allowed, :PATCH, [:GET, :POST]}} = Request.patch("/users") |> handle_request(:config)
  end

  test "fixed path segements generates path helper without args" do
    assert "/users" == path_to(:users)
  end

  test "fixed path segements generates url helper without args" do
    request = %Raxx.Request{host: "www.example.com", scheme: "http"}
    assert "http://www.example.com/users" == url_to(request, :users)
  end

  ## Variable path routing

  @route_name :user
  route ["users", user_id] do
    :GET ->
      {:get_user, user_id}
  end

  test "matches with path variables" do
    assert {:get_user, "bob"} = Request.get("/users/bob") |> handle_request(:config)
  end

  test "variables for path segements can be passed to path helper" do
    assert "/users/jill" == path_to(:user, ["jill"])
  end

  test "variables for path segements can be passed to uri helper" do
    request = %Raxx.Request{host: "www.example.com", scheme: "http", mount: ["api"]}
    assert "http://www.example.com/api/users/jill" == url_to(request, :user, ["jill"])
  end

  ## Middleware compliance

  def handle_request(_, _) do
    :legacy
  end

  test "not found route will be delegated to previous implementation" do
    assert :legacy = Request.get("/legacy") |> handle_request(:config)
  end

  ## Full request access

  route ["system"], request, config do
    :GET ->
      {request, config}
  end

  test "request and config are available to route actions" do
    request = Request.get("/system")
    config = :some_config
    assert {request, config} == handle_request(request, config)
  end

  # Enumerating routes

  test "all named routes are listed" do
    assert {:user, "[user_id]"} == routes |> List.keyfind(:user, 0)
    assert {:users, "[]"} == routes |> List.keyfind(:users, 0)
  end
end
