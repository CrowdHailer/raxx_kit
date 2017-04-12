defmodule TokumeiTest do
  # Redefine as stack test
  use ExUnit.Case

  use Tokumei

  # Streamline shouldn't need to import this however might need modification for error cases
  import Raxx.Response
  alias Raxx.Request

  route [] do
    :GET ->
      ok("Hello, World!")
    :PUT ->
      created("Onnit!")
  end

  error %NotFound{path: path} do
    path = "/" <> Enum.join(path, "/")
    not_found("Could not find #{path}")
  end

  test "content-length is set on response" do
    response = Request.get("/") |> handle_request(:config)
    assert {:ok, 13} == Raxx.ContentLength.fetch(response)
  end

  test "content is removed for a HEAD request" do
    response = Request.head("/") |> handle_request(:config)
    assert {:ok, 13} == Raxx.ContentLength.fetch(response)
    assert "" ==  response.body
  end

  test "random path returns result of error handler" do
    response = Request.get("random") |> handle_request(:config)
    assert 404 == response.status
  end

  test "can override method from query" do
    response = Request.post({"/", %{_method: "PUT"}}) |> handle_request(:config)
    assert 201 == response.status
  end

  @static "./static"

  test "will return contents from static file" do
    response = Request.get("/content.txt") |> handle_request(:config)
    assert {:ok, 9} == Raxx.ContentLength.fetch(response)
    assert "Content.\n" == response.body
  end

  test "head request returns info on static files" do
    response = Request.head("/content.txt") |> handle_request(:config)
    assert {:ok, 9} == Raxx.ContentLength.fetch(response)
    assert "" ==  response.body

  end
end
