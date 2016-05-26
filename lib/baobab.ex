defmodule Baobab do
  defmodule HomePageHandler do
    # DEBT options should inject dependency on Application
    def init({:tcp, :http}, req, []) do
      {:ok, req, :no_state}
    end

    def handle(request, :no_state) do
      {:ok, reply} = :cowboy_req.reply(ok, headers, body, request)
      {:ok, reply, :no_state}
    end

    def terminate(_reason, _request, :no_state) do
      :ok
    end

    defp ok do
      200
    end

    defp headers do
      [ {"content-type", "text/html"} ]
    end

    defp body do
      """
      Hello from the Baobab
      """
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

    dispatch = :cowboy_router.compile([
      {:_, [
        {"/static/[...]", :cowboy_static, {:priv_dir, :baobab, "static_files"}},
        {"/", HomePageHandler, []}
      ]}
    ])
    {:ok, _} = :cowboy.start_http(:http, 100, [{:port, 8080}], [{ :env, [{:dispatch, dispatch}]}])

  end
end
