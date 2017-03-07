defmodule Tokumei.Routing do
  @moduledoc """
  routing layer for Tokumei

  ## Issues

  - Impossible to know what methods are allowed because match can be arbitrarily complex
  """
  @known_methods [:GET, :POST, :PUT, :PATCH, :DELETE, :OPTIONS, :HEAD]

  defmacro __using__(_) do
    quote do
      import unquote(__MODULE__)
      # this import might belong in a html/response modules
      import Raxx.Response
      Module.register_attribute(__MODULE__, :route, accumulate: true)

      def handle_request(request = %{path: path, method: method}, env \\ nil) do
        route(path, method, request, env)
      end

      @before_compile unquote(__MODULE__)
      @route_name :unnamed
      @allowed []
    end
  end

  defmacro __before_compile__(_env) do
    quote do
      def route(_, _, %{path: path}, _env) do
        {:error, %Tokumei.Exceptions.NotFoundError{path: path}}
      end

      @routes Module.get_attribute(__MODULE__, :route)
      def routes() do
        @routes
      end
    end
  end

  defmacro route(path, vars, do: clauses) do
    match = build_match(path, vars)
    route_ast(path, match, clauses)
  end
  defmacro route(path, do: clauses) do
    match = build_match(path)
    route_ast(path, match, clauses)
  end

  for method <- @known_methods do
    defmacro unquote("#{method}" |> String.downcase |> String.to_atom)(request) do
      method = unquote(method)
      quote do
        {unquote(method), unquote(request), _env}
      end
    end
  end

  for method <- @known_methods do
    defmacro unquote("#{method}" |> String.downcase |> String.to_atom)(request, config) do
      method = unquote(method)
      quote do
        {unquote(method), unquote(request), unquote(config)}
      end
    end
  end

  defp route_ast(path, match, clauses) do
    clauses = clauses ++ quote do
      _request -> Raxx.Response.method_not_allowed("Method not allowed")
    end
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
