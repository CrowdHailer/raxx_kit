defmodule Tokumei.Router do

  defmacro route(path, do: clauses) do
    path = Raxx.Request.split_path(path)
    |> Enum.map(fn
      (":" <> var) -> Macro.var(var |> String.to_atom, nil)
      (segment) -> segment
    end)
    request_match = quote do: %{path: unquote(path)}
    methods = Enum.map(clauses, fn({:->, _, [[method], _action]}) -> method end) |> Enum.join(" ")
    quote do
      @before_compile Tokumei.Router
      @known_methods [:GET, :POST, :PUT, :PATCH, :DELETE, :OPTIONS, :HEAD]
      def handle_request(request = unquote(request_match), env) do
        unquote(Macro.var(:request, nil)) = request
        unquote(Macro.var(:env, nil)) = env
        case request.method do
          unquote(clauses ++ (quote do
            method when method in @known_methods ->
              Raxx.Response.method_not_allowed([{"allow", unquote(methods)}])
            _ ->
              Raxx.Response.not_implemented
          end))
        end
      end
    end
  end

  defmacro __before_compile__(env) do
    quote do
      def handle_request(_request, _config) do
        Raxx.Response.not_found()
      end
    end
  end
end
