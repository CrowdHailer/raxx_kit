defmodule Baobab.Web do
  defmodule Router do
    def handle_request(_, _) do
      body = "Hello, World!"
      Raxx.Response.ok(body)
    end
  end
  
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

  def handle_request(request, state) do
    response = Router.handle_request(request, state)
    headers = response.headers ++ [{"content-length", "#{:erlang.iolist_size(response.body)}"}]
    %{response | headers: headers}
  end
end
