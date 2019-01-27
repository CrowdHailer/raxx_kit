defmodule FormularTest do
  use ExUnit.Case, async: true
  doctest Formular

  setup %{} do
    # OS will assign a free port when service is started with port 0.
    {:ok, service} = Formular.WWW.start_link(%{}, port: 0, cleartext: true)
    {:ok, port} = Ace.HTTP.Service.port(service)

    {:ok, port: port}
  end

  test "Serves homepage", %{port: port} do
    assert {:ok, response} = :httpc.request('http://localhost:#{port}')
    assert {{_, 200, 'OK'}, _headers, _body} = response
  end
end
