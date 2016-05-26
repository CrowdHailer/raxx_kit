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

  # See http://elixir-lang.org/docs/stable/elixir/Application.html
  # for more information on OTP Applications
  def start(_type, _args) do
    import Supervisor.Spec, warn: false

    children = [
      # Define workers and child supervisors to be supervised
      # worker(Baobab.Worker, [arg1, arg2, arg3]),
    ]

    # See http://elixir-lang.org/docs/stable/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Baobab.Supervisor]
    Supervisor.start_link(children, opts)

    Plug.Adapters.Cowboy.http(RootController, %{})
  end
end
