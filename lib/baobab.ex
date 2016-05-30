defmodule RootPage do
  use HtmlView
end

defmodule Baobab do
  defmodule RootController do
    import Plug.Conn

    def init(opts) do
      opts
      |> Map.put(:greeting, "Hello")
      |> Map.put(:other, "<h1>&</h1>")
    end

    def call(conn, opts) do
      page = RootPage.html(opts)
      IO.inspect(page)
      send_resp(conn, 200, page)
    end
  end
  use Application

  def start(_type, _args) do
    Plug.Adapters.Cowboy.http(RootController, %{})
  end
end
