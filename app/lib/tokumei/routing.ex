defmodule Tokumei.Routing do
  @moduledoc """
  routing layer for Tokumei

  ## Issues

  - Impossible to know what methods are allowed because match can be arbitrarily complex
  ## Examples

  """
  @known_methods [:GET, :POST, :PUT, :PATCH, :DELETE, :OPTIONS]

  defmacro __using__(_) do
    quote do
      import unquote(__MODULE__), only: [route: 3]
      Module.register_attribute(__MODULE__, :route, accumulate: true)

      def handle_request(request = %{path: path, method: method}, config) do
        route(path, method, request, config)
      end

      @before_compile unquote(__MODULE__)
      @route_name :unnamed
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

  defmacro route(path, vars, do: actions) do
    {:{}, _, [request, config, params]} = vars
    {match, map} = build_match(path)
    |> IO.inspect
    allowed = Enum.map(actions, fn({:->, _, [[method], _]}) -> method end)
    # TODO add allowed
    actions = actions ++ quote do
      method -> Raxx.Response.method_not_allowed("Method not allowed")
    end
    map = Macro.escape(map)
    quote do
      @route {@route_name, unquote(path), unquote(allowed)}
      def route(array = unquote(match), method, unquote(request), unquote(config)) do
        unquote(params) = Enum.map(unquote(map), fn({k, i}) -> {k, Enum.at(array, i)} end) |> Enum.into(%{})
        case method do
          unquote(actions)
        end
      end

      # def path(@route_name) do
      #   "/" <> Enum.join(unquote(match), "/")
      # end
      @route_name :unnamed
    end
  end

  defp build_match(path) do
    build_match(Raxx.Request.split_path(path), [], 0, %{})
  end

  defp build_match([], reversed, _i, map) do
    {Enum.reverse(reversed), map}
  end
  defp build_match([":" <> key| segments], reversed, i, map) do
    # match = Keyword.get(kw, String.to_atom(key), quote do: _)
    map = Map.put(map, String.to_atom(key), i)
    |> IO.inspect
    reversed = [(quote do: _) | reversed]
    build_match(segments, reversed, i + 1, map)
  end
  defp build_match([segment| segments], reversed, i, map) do
    reversed = [segment | reversed]
    build_match(segments, reversed, i + 1, map)
  end
end
