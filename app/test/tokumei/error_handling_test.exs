defmodule Tokumei.ErrorHandlingTest do
  use ExUnit.Case
  alias Raxx.Request

  use Tokumei
  use Tokumei.Exceptions

  route "/foo" do
    get(_r) ->
      {:error, :my_error}
  end

  error %NotFoundError{path: path} do
    not_found(path)
  end

  test "not found error is available for missing route" do
    response = Request.get("/random") |> handle_request()
    assert 404 = response.status
    assert ["random"] = response.body
  end

  error :my_error do
    gateway_timeout("my error")
  end

  test "custom errors are also passed to error callback" do
    response = Request.get("/foo") |> handle_request()
    assert 504 = response.status
    assert "my error" = response.body
  end

end
