defmodule Tokumei.RouterTest do
  use ExUnit.Case
  alias Raxx.Request
  alias Raxx.Response

  defmodule ConnectionLogger do
    def handle_request(request, {next, conf}) do
      next.(request)
    end
  end

  use Tokumei.Router

  @middleware {Tokumei.Router.ContentLength, nil}
  @middleware {ConnectionLogger, :config2}

  route "foo" do
    :GET -> Response.ok("foo")
    :POST -> Response.no_content()
  end

  test "Will match on a single path element" do
    response = %{status: status, body: body} = get("/foo")
    assert 200 == status
    assert "foo" == body
    assert {:ok, 3} == Raxx.ContentLength.fetch(response)
  end

  test "Will match on any method single path element" do
    %{status: status, body: body} = post("/foo")
    assert 204 == status
  end

  error %NotImplementedError{} do
    Response.not_implemented()
  end

  error %MethodNotAllowedError{allowed: allowed} do
    Raxx.Response.method_not_allowed([{"allow", allowed |> Enum.join(" ")}])
  end

  test "Will return method not allowed for other methods" do
    response = patch("/foo")
    assert 405 == response.status
    assert "GET POST" == :proplists.get_value("allow", response.headers)
  end

  test "Will return not implemented for unknown methods" do
    response = %{Raxx.Request.get("/foo") | method: :PZAZZ} |> handle_request(:empty_env)
    assert 501 == response.status
  end

  route "parameter/:id" do
    :GET -> Response.ok("parameter: #{id}")
  end

  test "Will pass match variables into the action" do
    response = get("/parameter/1")
    assert "parameter: 1" == response.body
  end

  route "bar" do
    :GET ->
      send(self(), request)
      Response.ok()
  end

  test "Will handle multiple lines single path element" do
    assert 200 == get("/bar").status
  end

  error %NotFoundError{request: request} do
    Response.not_found
  end

  test "Will return a 404 for not found" do
    assert 404 == get("/random").status
  end

  route "/server-error" do
    :GET -> {:error, :oops}
  end

  test "Will return a 500 for other error" do
    assert 500 == get("/server-error").status

  end

  mount "/subapp", __MODULE__

  route "/level-two" do
    :GET ->
      send(self(), request)
      Response.ok()
  end

  test "can mount a sub app" do
    assert 200 == get("/subapp/level-two").status
    assert_receive %{mount: ["subapp"], path: ["level-two"]}
  end

  defp get(path) do
    Request.get(path)
    |>  __MODULE__.handle_request(:empty_env)
  end

  defp post(path) do
    Request.post(path)
    |>  __MODULE__.handle_request(:empty_env)
  end

  defp patch(path) do
    Request.patch(path)
    |>  __MODULE__.handle_request(:empty_env)
  end
end
