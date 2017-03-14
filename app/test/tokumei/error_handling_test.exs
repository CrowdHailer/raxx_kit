defmodule Tokumei.ErrorHandlingTest do
  @moduledoc """
  error any do
    report_exception(any)
    MyException.display_html(exceptin)
  end

  """
  use ExUnit.Case
  alias Raxx.Request

  use Tokumei
  use Tokumei.Exceptions
  import Raxx.Response

  route "/foo", {_,_,_} do
    :GET ->
      {:error, :my_error}
  end

  error %NotFoundError{path: path} do
    not_found(path)
  end

  test "not found error is available for missing route" do
    response = Request.get("/random") |> handle_request(:config)
    assert 404 = response.status
    assert ["random"] = response.body
  end

  error :my_error do
    gateway_timeout("my error")
  end

  test "custom errors are also passed to error callback" do
    response = Request.get("/foo") |> handle_request(:config)
    assert 504 = response.status
    assert "my error" = response.body
  end

end
