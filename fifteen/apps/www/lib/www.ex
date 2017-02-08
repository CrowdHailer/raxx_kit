defmodule Fifteen.WWW do
  use Application

  def start(_type, _args) do
    import Supervisor.Spec, warn: false

    children = [
      worker(Ace.HTTP, [{Fifteen.WWW.Router, []}, [port: 8080]])
    ]

    opts = [strategy: :one_for_one, name: Fifteen.WWW.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
