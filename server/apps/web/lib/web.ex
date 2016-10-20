defmodule Baobab.Web do
  use Application

  @raxx_app {__MODULE__, []}

  def start(_type, _args) do
    import Supervisor.Spec, warn: false

    children = [
      worker(Ace.TCP, [{Raxx.Adapters.Ace.Handler, @raxx_app}, [port: 8080]])
    ]

    opts = [strategy: :one_for_one, name: Baobab.Web.Supervisor]
    Supervisor.start_link(children, opts)
  end

  def handle_request(_, _) do
    body = "hello"
    Raxx.Response.ok(body, [{"content-length", "#{:erlang.iolist_size(body)}"}])
  end
end
