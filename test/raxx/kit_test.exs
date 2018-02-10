defmodule Raxx.KitTest do
  use ExUnit.Case
  doctest Raxx.Kit

  test "greets the world" do
    assert Raxx.Kit.hello() == :world
  end
end
