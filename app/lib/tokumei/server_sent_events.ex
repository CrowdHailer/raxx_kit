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
  #
  defmacro streaming(do: clauses) do
    ast = for {:->, _, [[match], action]} <- clauses do
      quote do
        def handle_info(unquote(match), state) do
          case unquote(action) do
            {:send, message} when is_binary(message) ->
              {:chunk, "event: chat\ndata: #{message}\n\n", state}
          end
        end
      end
    end
    {:__block__, [], ast}
  end
end
