defmodule Tokumei.Router do
  defmodule NotFoundError do
    defexception message: nil, request: nil
  end

  defmodule NotImplementedError do
    defexception message: nil, request: nil
  end

  defmodule MethodNotAllowedError do
    defexception message: nil, request: nil, allowed: nil
  end

  defmacro mount(mount, app) do
    # TODO need multilevel mount
    [mount] = Raxx.Request.split_path(mount)
    rest = quote do: rest
    path = [{:|, [], [mount, rest]}]

    request_match = quote do: %{path: unquote(path)}
    quote do
      def handle_request(request = unquote(request_match), env) do
        # TODO add previous mounting.
        request = %{request | path: rest, mount: [unquote(mount)]}
        unquote(app).handle_request(request, env)
      end
    end
  end

  defmacro route(path, do: clauses) do
    path = Raxx.Request.split_path(path)
    |> Enum.map(fn
      (":" <> var) -> Macro.var(var |> String.to_atom, nil)
      (segment) -> segment
    end)
    request_match = quote do: %{path: unquote(path)}
    methods = Enum.map(clauses, fn({:->, _, [[method], _action]}) -> method end)
    quote do
      @before_compile Tokumei.Router
      @known_methods [:GET, :POST, :PUT, :PATCH, :DELETE, :OPTIONS, :HEAD]
      def handle_request(request = unquote(request_match), env) do
        unquote(Macro.var(:request, nil)) = request
        unquote(Macro.var(:env, nil)) = env
        case request.method do
          unquote(clauses ++ (quote do
            method when method in @known_methods ->
              {:error, %MethodNotAllowedError{request: request, allowed: unquote(methods)}}
            _ ->
              {:error, %NotImplementedError{request: request}}
          end))
        end
        |> case do
          {:error, exception} ->
            on_error(exception)
          other ->
            other
        end
        |> check_length
      end
    end
  end

  defmacro error filter, do: handler do
    quote do
      def on_error(unquote(filter)) do
        unquote(handler)
      end
    end
  end

  defmacro __before_compile__(env) do
    quote do
      def handle_request(request, _config) do
        exception = %Tokumei.Router.NotFoundError{request: request}
        on_error(exception)
        |> check_length
      end

      def on_error(exception) do
        Raxx.Response.internal_server_error()
      end

      # TODO Use a middleware to work this out
      defp check_length(response = %{headers: headers, body: body}) do
        headers = if !List.keymember?(headers, "content-length", 0) do
          headers ++ [{"content-length", "#{:erlang.iolist_size(body)}"}]
        else
          headers
        end
        %{response | headers: headers}
      end
    end
  end
end
