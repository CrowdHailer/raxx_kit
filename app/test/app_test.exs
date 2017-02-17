defmodule TokumeiTest do
  use ExUnit.Case
  doctest Tokumei

  import Tokumei.Helpers
  route "/home" do
    get(request, env) ->
      {request, env}
  end

  route "/other" do
    get(request) ->
      request
  end

  route("/params/:a/:b/:c", {a, b, c}) do
    get() ->
      {a, b, c}
  end
  route(["other", a, b, c]) do
    get() ->
      {a, b, c}
  end

  # route("users/:id") do
  #   get(request, env) -> UsersController.show(request, env)
  #   put(request, env) -> UsersController.update(request, env)
  #   delete(request, env) -> UsersController.remove(request, env)
  # end

  test "get home" do
    Raxx.Request.get("/home")
    |> __MODULE__.handle_request(:nil)
    |> IO.inspect
    Raxx.Request.post("/home")
    |> __MODULE__.handle_request(:nil)
    |> IO.inspect
    Raxx.Request.get("/other")
    |> __MODULE__.handle_request(:nil)
    |> IO.inspect
    Raxx.Request.get("/params/1/2/3")
    |> __MODULE__.handle_request(:nil)
    |> IO.inspect
    Raxx.Request.get("/other/1/2/3")
    |> __MODULE__.handle_request(:nil)
    |> IO.inspect
  end
end
