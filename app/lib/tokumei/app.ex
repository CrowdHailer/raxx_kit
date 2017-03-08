defmodule Tokumei.App do
  defmacro __using__(_opts) do
    quote do
      # @before_compile unquote(__MODULE__)
      use Application
      def start(_type, _args) do
        import Supervisor.Spec, warn: false

        port = @port || 8080
        true = Code.ensure_loaded?(Ace.HTTP)
        children = [
          worker(Ace.HTTP, [{__MODULE__, []}, [port: port, name: __MODULE__]])
        ]

        opts = [strategy: :one_for_one, name: Tokumei.Supervisor]
        Supervisor.start_link(children, opts)
      end
    end
  end

end
