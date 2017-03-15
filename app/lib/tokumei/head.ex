defmodule Tokumei.Head do
  @moduledoc """
  Transform HEAD requests to GET requests.

  Returns responses with the body removed.
  """
  defmacro __using__(_opts) do
    quote location: :keep do
      @before_compile unquote(__MODULE__)
    end
  end
  defmacro __before_compile__(_env) do
    quote do
      defoverridable [handle_request: 2]

      def handle_request(request = %{method: :HEAD}, config) do
        request = %{request | method: :GET}
          case super(request, config) do
            response = %{body: _body} ->
              %{response | body: ""}

            # TODO don't send chunked content just send the headers saying you would
            upgrade = %Raxx.Chunked{} ->
              upgrade
          end
      end
      def handle_request(request, config) do
        super(request, config)
      end
    end
  end
end
