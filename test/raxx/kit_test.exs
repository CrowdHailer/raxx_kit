defmodule Raxx.KitTest do
  use ExUnit.Case
  doctest Raxx.Kit

  import Raxx.Kit

  describe "generate_random/1" do
    test "generates strings of the correct length" do
      assert 8 = String.length(generate_random(8))
      assert 13 = String.length(generate_random(13))
      assert 134 = String.length(generate_random(134))
    end

    test "generates strings with no weird characters" do
      password = generate_random(333)
      assert Regex.match?(~r/^$/, "")
      assert Regex.match?(~r/^[0-9a-zA-Z_]+$/, password)
    end
  end
end
