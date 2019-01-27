defmodule Formular.WWW.Actions.HomePageTest do
  use ExUnit.Case

  alias Formular.WWW.Actions.HomePage

  test "test the form" do
    request =
      Raxx.request(:POST, "/")
      |> Raxx.set_body("name=Bob&age=-1")

    response = HomePage.handle_request(request, %{})

    assert response.status == 200
    assert {"content-type", "text/html"} in response.headers
    # assert String.contains?(IO.iodata_to_binary(response.body), "Raxx.Kit")
  end
end
