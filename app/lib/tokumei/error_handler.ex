defmodule Tokumei.ErrorHandler do
  @moduledoc """
  Handle failures from request handlers.

  Extension to the Raxx interface to provide better error handling.
  `Tokumei.ErrorHandler` modifies all responses of the form `{:error, reason}`.
  It will first match the reason against the appropriate failure handler.
  If no failure handler matches it will return a default 500 response.

  *Using `Tokumei.ErrorHandler` will alias all Tokumei Exceptions.*

      defmodule MyApp.Router do
        use Tokumei.NotFound
        use Tokumei.Router
        use Tokumei.ErrorHandler

        import Raxx.Response

        route "/checkout" do
          post(request) ->

            # Actions can return an exception as the reason for a error tuple
            {:error, :subscription_expired}
        end

        # Any error can be handled using an error block
        error :subscription_expired do

          # payment_required/1 returns a Raxx.Response with status 402
          payment_required("Please pay up, :-)")
        end

        # Routing errors can also be intercepted
        error %NotFound{path: path} do
          path = "/" <> Enum.join(path, "/")

          # For example, to send a custom response message.
          not_found("Could not find \#{path}")
        end
      end
  """

  defmacro __using__(_opts) do
    quote do
      import unquote(__MODULE__)
      alias Tokumei.NotFound

      @before_compile unquote(__MODULE__)
    end
  end

  defmacro __before_compile__(_env) do
    quote do
      defoverridable [handle_request: 2]

      def handle_request(request, env) do
        case super(request, env) do
          {:error, exception} ->
            handle_error(exception)
          other ->
            other
        end
      end

      def handle_error(reason) do
        Raxx.Response.internal_server_error("Unhandled failure: {:error, #{inspect(reason)}}")
      end
    end
  end

  defmacro error(exception, do: handler) do
    quote do
      def handle_error(unquote(exception)) do
        unquote(handler)
      end
    end
  end
end
