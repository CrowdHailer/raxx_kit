defmodule StreamingTest do
  # defmodule App do
  #   use Tokumei
  #
  #   route "/" do
  #     get(_, pid) ->
  #       send(pid, {:server, self()})
  #       SSE.stream(self())
  #   end
  #
  #   SSE.streaming() do
  #     {:message, message} ->
  #       {:send, message}
  #   end
  # end
  # use ExUnit.Case
  #
  # test "" do
  #   request = Raxx.Request.get("/")
  #   %Raxx.Chunked{app: {mod, state}} = App.handle_request(request, self)
  #   mod.handle_info({:message, "Hello!"}, state)
  #   |> IO.inspect
  # end
end
