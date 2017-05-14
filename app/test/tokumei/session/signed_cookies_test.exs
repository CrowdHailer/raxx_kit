defmodule Tokumei.Session.SignedCookiesTest do
  use ExUnit.Case

  alias Raxx.{Request, Response}
  alias Tokumei.Session.SignedCookies
  doctest Tokumei.Session.SignedCookies

  use Tokumei.NotFound
  use Tokumei.Router
  import Raxx.Response
  use Tokumei.Session.SignedCookies

  @secret "eggplant"

  route ["session", first_value] do
    :PUT ->
      new_session = %{"first" => first_value}
      ok("Session set", [{"tokumei-session", new_session}])
  end

  route ["session", first_value, second_value] do
    :PUT ->
      new_session = %{"first" => first_value, "second" => second_value}
      ok("Session set", [{"tokumei-session", new_session}])
  end

  route ["session"], request do
    :GET ->
      session = :proplists.get_value("tokumei-session", request.headers)
      value = Map.get(session, "first", "none-set")
      ok("Session value: #{value}")
    :DELETE ->
      new_session = %{}
      ok("Session set", [{"tokumei-session", new_session}])
  end

  test "Session middleware e2e" do
    response = handle_request(Request.put("/session/foo/bar"), nil)
    headers = get_all_set_cookies(response)
    |> Enum.map(&set_cookie_to_sent_cookie/1)

    assert headers == [
      {"cookie", "first=foo"},
      {"cookie", "second=bar"},
      {"cookie", "tokumei.session=first second -- C%2FGoXyhA0ZD%2BSFsgkSisOKUL6ko%3D"}]


    response = handle_request(Request.put("/session/baz", headers), nil)
    headers2 = get_all_set_cookies(response)
    |> Enum.map(&set_cookie_to_sent_cookie/1)

    assert headers2 = [
      {"cookie", "second="},
      {"cookie", "first=baz"},
      {"cookie", "tokumei.session=first -- UAz8f8syzn37Fn%2Fp8PvDyRa0zXk%3D"}]

    response = handle_request(Request.get("/session", headers2), nil)
    assert "Session value: baz" == response.body


    response = handle_request(Request.delete("/session", headers), nil)
    headers = get_all_set_cookies(response)
    assert "tokumei.session=; path=/; expires=Thu, 01 Jan 1970 00:00:00 GMT; max-age=0; HttpOnly" == List.last(headers)
  end

  defp set_cookie_to_sent_cookie(value) do
    {"cookie", value |> String.split(";") |> List.first}
  end

  # TODO ugrade raxx_cookie
  def get_all_set_cookies(%{headers: headers}) do
    :proplists.get_all_values("set-cookie", headers)
  end
end
