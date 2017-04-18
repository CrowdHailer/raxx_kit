defmodule Tokumei.ErrorHandlerTest do
  use ExUnit.Case
  alias Raxx.Request
  alias Raxx.Response

  use Tokumei.NotFound
  use Tokumei.ErrorHandler

  def handle_request(%{path: ["handled"]}, _), do: {:error, :handled_error}
  def handle_request(%{path: ["unhandled"]}, _), do: {:error, :unhandled_error}

  error :handled_error do
    Response.gateway_timeout()
  end

  test "error callback is called with the reason from an failure tuple" do
    response = Request.get("/handled") |> handle_request(:config)
    assert 504 = response.status
  end

  test "unhandled error is returned as a server error" do
    response = Request.get("/unhandled") |> handle_request(:config)
    assert 500 = response.status
    assert "Unhandled failure: {:error, :unhandled_error}" = response.body
  end

  error %NotFoundError{path: path} do
    Response.not_found(path)
  end

  test "not found error is available for missing route" do
    response = Request.get("/not_found") |> handle_request(:config)
    assert 404 = response.status
    assert ["not_found"] = response.body
  end
end
