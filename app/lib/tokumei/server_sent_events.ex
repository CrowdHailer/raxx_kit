defmodule Tokumei.ServerSentEvents do
  def stream(mod, config) do
    Raxx.Chunked.upgrade({mod, config}, headers: [
      {"cache-control", "no-cache"},
      {"transfer-encoding", "chunked"},
      {"connection", "keep-alive"},
      {"content-type", "text/event-stream"}
    ])
  end

  defmacro stream(config \\ :config) do
    quote do
      unquote(__MODULE__).stream(__MODULE__, unquote(config))
    end
  end
end
