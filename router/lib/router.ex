defmodule Tokumei.Router do
  defmacro route(path, do: clauses) do
    path = Raxx.Request.split_path(path)
    request_match = quote do: %{path: unquote(path)}
    methods = Enum.map(clauses, fn({:->, _, [[method], _action]}) -> method end) |> Enum.join(" ")
    quote do
      def handle_request(request = unquote(request_match), env) do
        unquote(Macro.var(:request, nil)) = request
        unquote(Macro.var(:env, nil)) = env
        case request.method do
          unquote(clauses ++ (quote do
            method when method in [:PATCH] ->
              Raxx.Response.method_not_allowed([{"allow", unquote(methods)}])
            _ ->
              Raxx.Response.not_implemented
          end))
        end
      end
    end
  end
end
