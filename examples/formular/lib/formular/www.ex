defmodule Formular.WWW do
  def child_spec([config, server_options]) do
    {:ok, port} = Keyword.fetch(server_options, :port)

    %{
      id: {__MODULE__, port},
      start: {__MODULE__, :start_link, [config, server_options]},
      type: :supervisor
    }
  end

  @external_resource "lib/formular/public/main.css"
  @external_resource "lib/formular/public/main.js"
  @static_setup Raxx.Static.setup(source: Path.join(__DIR__, "public"))

  def start_link(config, server_options) do
    stack =
      Raxx.Stack.new(
        [
          {Raxx.Static, @static_setup}
        ],
        {__MODULE__.Router, config}
      )

    Ace.HTTP.Service.start_link(stack, server_options)
  end
end
