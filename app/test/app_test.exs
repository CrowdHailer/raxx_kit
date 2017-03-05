defmodule TokumeiTest do
  use ExUnit.Case
  doctest Tokumei

  test "pids" do
    :gproc.reg({:p, :l, :topic})
    |> IO.inspect
    :gproc.lookup_pids({:p, :l, :topic})
    |> IO.inspect
    :gproc.send({:p, :l, :topic}, "message")
    |> IO.inspect
    receive do
      any -> IO.inspect(any)
    end
  end
end
