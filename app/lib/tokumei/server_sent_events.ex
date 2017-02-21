defmodule Tokumei.ServerSentEvents do
  def stream(id) do
    Raxx.Chunked.upgrade({Example, id}, headers: [
      {"cache-control", "no-cache"},
      {"transfer-encoding", "chunked"},
      {"connection", "keep-alive"},
      {"content-type", "text/event-stream"}
    ])
  end
end
