defmodule Tokumei.MethodOverrideTest do
  use ExUnit.Case
  import Tokumei.MethodOverride
  import Raxx.Request
  # doctest Tokumei.MethodOverride

  def handle_request(request, _) do
    request
  end

  # use Tokumei.MethodOverride

end
