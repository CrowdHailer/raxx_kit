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
    mods = [{mod1, conf1}, {mod2, conf2}] = Module.get_attribute(env.module, :middleware)
    quote do
      def handle_request(request, _config) do
        {:error, %Tokumei.Router.NotFoundError{request: request}}
      end

      def on_error(exception) do
        Raxx.Response.internal_server_error()
      end

      defoverridable [handle_request: 2]

      def handle_request(request, env) do
        router = &super(&1, env)
        next = fn(request) ->
          case router.(request) do
            {:error, exception} ->
              on_error(exception)
            other ->
              other
          end
        end
        Enum.reduce(unquote(mods), next, fn
          ({mod, conf}, next) -> fn(r) -> mod.handle_request(r, {next, conf})end
        end).(request)
      end
    end
  end
end
