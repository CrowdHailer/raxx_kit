defmodule Tokumei.Router do
  defmacro route(path, do: clauses) do
    path = Raxx.Request.split_path(path)
    request_match = quote do: %{path: unquote(path)}
    quote do
      def handle_request(request = unquote(request_match), env) do
        unquote(Macro.var(:request, nil)) = request
        unquote(Macro.var(:env, nil)) = env
        case request.method do
          unquote(clauses)
        end
      end
    end
  end
end
