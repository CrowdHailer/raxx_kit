defmodule Baobab do
  defmodule RootController do
    import Plug.Conn

    def init(opts) do
      Map.put(opts, :my_option, "Hello")
    end

    def call(conn, opts) do
      send_resp(conn, 200, "#{opts[:my_option]}, World!")
    end
  end
  use Application

  def start(_type, _args) do
    Plug.Adapters.Cowboy.http(RootController, %{})
  end
end
