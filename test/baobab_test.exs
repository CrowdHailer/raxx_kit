defmodule BaobabTest do
  use ExUnit.Case, async: true
  use Plug.Test

  test "root page returns 200" do
    opts = Baobab.RootController.init(%{})
    conn = conn(:get, "/")
    conn = Baobab.RootController.call(conn, opts)

    assert conn.state == :sent
    assert conn.status == 200
    assert String.contains?(conn.resp_body, "Hello")
  end
end
