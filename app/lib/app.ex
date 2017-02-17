defmodule Tokumei do
  use Application

  # See http://elixir-lang.org/docs/stable/elixir/Application.html
  # for more information on OTP Applications
  def start(_type, _args) do
    import Supervisor.Spec, warn: false

    # Define workers and child supervisors to be supervised
    children = [
      # Starts a worker by calling: Tokumei.Worker.start_link(arg1, arg2, arg3)
      # worker(Tokumei.Worker, [arg1, arg2, arg3]),
    ]

    # See http://elixir-lang.org/docs/stable/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Tokumei.Supervisor]
    Supervisor.start_link(children, opts)
  end

  defmodule Helpers do
    defp build_match(segments, vars, reversed \\ [])
    defp build_match([], [], reversed) do
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
    defmacro route(path, {:{}, _, vars}, do: clauses) do
      path = build_match(Raxx.Request.split_path(path), vars)
      request_match = quote do: %{path: unquote(path)}
      quote do
        def handle_request(request = unquote(request_match), env) do
          case {request.method, request, env} do
            unquote(clauses)
          end
        end
      end
    end
    defmacro route(path, do: clauses) do
      path = Raxx.Request.split_path(path)
      request_match = quote do: %{path: unquote(path)}
      clauses = clauses ++ (quote do
        request -> {:error, :not_allowed}
      end)
      quote do
        def handle_request(request = unquote(request_match), env) do
          case {request.method, request, env} do
            unquote(clauses)
          end
        end
      end
    end

    defmacro get(request, env) do
      quote do: {:GET, unquote(request), unquote(env)}
    end
    defmacro get(request) do
      quote do: {:GET, unquote(request), _}
    end
    defmacro get() do
      quote do: {:GET, _, _}
    end
  end

  def __using__(opts) do
    IO.inspect(opts)
    quote do
      require Tokumei.Helpers
    end
  end
end
