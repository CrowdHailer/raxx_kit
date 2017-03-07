defmodule Tokumei.MethodOverrideTest do
  use ExUnit.Case
  import Tokumei.MethodOverride
  import Raxx.Request
  doctest Tokumei.MethodOverride

  def handle_request(request, _) do
    request
  end

  use Tokumei.MethodOverride

  test "override POST to PUT from query value" do
    response = post({"/", %{"_method" => "PUT"}})
    |> handle_request(nil)
    assert %{method: :PUT} = response
  end
end
