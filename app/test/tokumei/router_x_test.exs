defmodule Tokumei.RouterX do
  @moduledoc """
  Simplest Router for Raxx Applications

  imports one macro `route/2/3/4`

  tries to call super
  returnes an error for method not allowed

  # middleware for known_methods therefore no when clause needed and no

  """
  defmacro __using__(_) do
    quote do
      # import unquote(__MODULE__), only: [route: 4]
      import unquote(__MODULE__)
      Module.register_attribute(__MODULE__, :route, accumulate: true)

      @before_compile unquote(__MODULE__)
      @route_name :unnamed
    end
  end

  # Not found should return errors.
  # Saying it should be pared with an error handler is no problem.
  # things it does not know how to do need to be solved elseware
  # router has no concept of rendering a response
  # choice of Raxx.NotFoundError or Tokumei.Router.NotFoundError
  # should call super for 404 anyways
  # method not implemented can be caught by a middleware previously
  # test against all matches for 405 enum matches
  # Could just work for the moment with a final method not allowed step
  defmacro __before_compile__(_env) do
    quote do

      def handle_route(_, _, %{path: path}, _env) do
        # NotFoundError.triggered_by(request, env: :prod, user: :Jill)
        # super
        {:error, %Tokumei.Exceptions.NotFoundError{path: path}}
      end

      def handle_request(request = %{path: path, method: method}, config) do
        handle_route(path, method, request, config)
      end

      @routes Module.get_attribute(__MODULE__, :route)
      def routes() do
        @routes
      end

      def path(name, vars \\ []) do
        raxx_path(name, List.wrap(vars))
        |> Enum.join("/")
        # Possibly should not add this path is relative if mounting is a possibility
        |> (&("/" <> &1)).()
      end

      def url(request, name, vars) do
        path = raxx_path(name, List.wrap(vars))
        |> Enum.join("/")
        request = %{request | path: path}
      end
    end
  end

  @doc """
  Short version of `route/4` for convenience

  ```elixir
  route "/my/path", do
    # actions
  end

  route "/my/path", _request, _config do
    # actions
  end
  ```
  """
  defmacro route(match, do: actions) do
    quote do
      route unquote(match), _, _, do: unquote(actions)
    end
  end
  defmacro route(match, request, do: actions) do
    quote do
      route unquote(match), unquote(request), _, do: unquote(actions)
    end
  end
  defmacro route(match, request, config, do: actions) do
    args = Enum.reject(match, &(is_binary(&1)))

    drop = quote do: _
    quote do
      defp raxx_path(@route_name, unquote(args)) do
        unquote(match)
      end
      def handle_route(unquote(match), method, unquote(request), unquote(config)) do
        case method do
          unquote(actions)
        end
      end
    end
  end
end
defmodule Tokumei.RouterXTest do
  use ExUnit.Case
  use Tokumei.RouterX

  @route_name :foo
  route ["foo"], request, config do
    :GET ->
      IO.inspect(request)
      IO.inspect(config)
      :get_foo
  end

  @route_name :show_user
  route ["user", id], request, config do
    :GET ->
      :get_foo
  end

  test "matches on a fixed path" do
    response = Raxx.Request.get("/foo")
    |> handle_request(:config)
    path(:foo)
    |> IO.inspect
  end
  test "matches on a variable path" do
    response = Raxx.Request.get("/user/23")
    |> handle_request(:config)
    |> IO.inspect
    path(:show_user, "23")
    |> IO.inspect
  end
end
