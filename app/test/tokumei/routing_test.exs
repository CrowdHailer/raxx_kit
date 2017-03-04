defmodule Tokumei.Routing do
  @known_methods [:GET, :POST, :PUT, :PATCH, :DELETE, :OPTIONS, :HEAD]

  defmacro __using__(_) do
    quote do
      import unquote(__MODULE__)
      Module.register_attribute(__MODULE__, :route, accumulate: true)
      Module.register_attribute(__MODULE__, :method, accumulate: true)

      def handle_request(request = %{path: path, method: method}, env \\ nil) do
        route(path, method, request, env)
      end

      @before_compile unquote(__MODULE__)
      @allowed []
    end
  end

  defmacro __before_compile__(_env) do
    quote do
      def route(_, _, request, env) do
        Raxx.Response.not_found("Not Found")
      end

      @routes Module.get_attribute(__MODULE__, :route)
      |> IO.inspect
      @methods Module.get_attribute(__MODULE__, :method)
      |> IO.inspect
      def routes() do
        @routes
      end
    end
  end

  defmacro route(path, vars, do: clauses) do
    match = build_match(path, vars)
    quote do
      @route {@route_name, unquote(path), @allowed}
      def route(unquote(match), method, request, env) do
        case {method, request, env} do
          unquote(clauses)
        end
      end
      @route_name :unnamed
      @allowed []
    end
  end
  defmacro route(path, do: clauses) do
    match = build_match(path)
    test = clauses
    |> Enum.map(fn
      ({:->, env, [match, action]}) -> {:->, env, [map_method_match(match), "action"]}
    end)
    test = test ++ quote do
      a -> :failes
    end
    # I think it is impossible to work out the allowed methods when we include all match cases.
    x = quote do
        case {:PATCH, %{}, %{}} do
          unquote(test)
        end
    end
    quote do
      # IO.inspect(__ENV__)
      clauses = Macro.expand_once(unquote(x), __ENV__)
      |> IO.inspect
      # |> Macro.expand(__ENV__)
      # |> IO.inspect
      # |> Enum.map(fn(_) -> [] end)
      IO.inspect(@allowed)
      @route {@route_name, unquote(path), @allowed}
      def route(unquote(match), method, request, env) do
        case {method, request, env} do
          unquote(clauses)
        end
      end
      @route_name :unnamed
      @allowed []
    end
  end

  def map_method_match(a) do
    a
  end

  for method <- @known_methods do
    defmacro unquote("#{method}" |> String.downcase |> String.to_atom)(request) do
      method = unquote(method)
      quote do
        {unquote(method), unquote(request), _env}
      end
    end
  end


  defp build_match(path, vars \\ quote do: {})
  defp build_match(path, {:{}, _, vars}) do
    build_match(Raxx.Request.split_path(path), vars, [])
  end

  defp build_match([], _, reversed) do
    Enum.reverse(reversed)
  end
  defp build_match([":" <> _| segments], [var | vars], reversed) do
    reversed = [var | reversed]
    build_match(segments, vars, reversed)
  end
  defp build_match([segment| segments], vars, reversed) do
    reversed = [segment | reversed]
    build_match(segments, vars, reversed)
  end
end
defmodule Tokumei.RoutingTest do
  use ExUnit.Case
  alias Raxx.Request

  use Tokumei.Routing
  import Raxx.Response

  @route_name :foo
  @allowed [:GET, :POST]
  route "/foo" do
    a = get(_request) ->
      ok("get")
    post(_request) ->
      ok("post")
  end

  test "matches on a single path element" do
    response = Request.get("/foo") |> handle_request()
    assert 200 = response.status
    assert "get" = response.body
  end

  test "matches correct method on single path element" do
    response = Request.post("/foo") |> handle_request()
    assert 200 = response.status
    assert "post" = response.body
  end

  test "route is added to the list of routes, with name" do
    assert Enum.member?(routes, {:foo, "/foo", [:GET, :POST]})
  end

  @tag :skip
  test "will return method not allowed for un implemented methods" do
    response = Request.delete("/foo") |> handle_request()
    assert 405 = response.status
    assert "Method not allowed" = response.body
  end

  test "will return not found for unimplemented route" do
    response = Request.get("/random") |> handle_request()
    assert 404 = response.status
    assert "Not Found" = response.body
  end

  route "/variables/:a/:b/:c/", {x, y, z} do
    get(_request) ->
      ok({x, y, z})
  end

  test "assign path variables to provided variables" do
    response = Request.get("/variables/a1/b2/c3") |> handle_request()
    assert {"a1", "b2", "c3"} == response.body
  end
end
