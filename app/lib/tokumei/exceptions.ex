# Unexpected
defmodule Tokumei.Exceptions do
  defmodule NotFoundError do
    defexception message: nil, path: nil
  end

  defmacro __using__(_opts) do
    quote do
      import unquote(__MODULE__)
      alias unquote(__MODULE__).{
        NotFoundError
      }



      @before_compile unquote(__MODULE__)
    end
  end

  defmacro __before_compile__(_env) do
    quote do
      defoverridable [handle_request: 2]

      def handle_request(request, env) do
        case super(request, env) do
          {:error, exception} ->
            # DEBT shouldn't need to call off __MODULE__ once a default on_error is implemented
            __MODULE__.on_error(exception)
          other ->
            other
        end
      end

      def on_error(%Tokumei.Exceptions.NotFoundError{}) do
        Raxx.Response.not_found("Not Found")
      end
    end
  end

  defmacro error(exception, do: handler) do
    quote do
      def on_error(unquote(exception)) do
        unquote(handler)
      end
    end
  end
end
