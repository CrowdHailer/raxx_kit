defmodule Example do
  use Tokumei
  import Tokumei.Helpers

  config :port, 8989

  route "/home" do
    get(request, env) ->
      {request, env}
  end

  route "/other" do
    get(request) ->
      request
  end

  route("/params/:a/:b/:c", {a, b, c}) do
    get() ->
      {a, b, c}
  end
  route(["other", a, b, c]) do
    get() ->
      {a, b, c}
  end

end
