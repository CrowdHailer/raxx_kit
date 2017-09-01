defmodule Tokumei.Flash.QueryTest do
  # TODO write a generic transfer test case in transfer module. Implement behaviour and test against.
  use ExUnit.Case

  alias Raxx.Response
  alias Raxx.Request
  alias Tokumei.Flash
  # doctest Tokumei.Flash.Query

  # use Flash.Query

  def handle_request(request, messages) do
    [{tag, content}] = Flash.read(request)
    Response.see_other("#{tag} - #{content}")
    |> Raxx.Location.set("/")
    |> Flash.write(messages)
  end

  @tag :skip
  test "test integration as a tokumei middleware" do
    response = Request.get("/?_flash[]=info%3Amy+info")
    |> handle_request([info: "my reply"])
    assert "info - my info" == response.body
    assert [{"location", "/?_flash%5B%5D=info%3Amy+reply"}] == response.headers
  end
end
