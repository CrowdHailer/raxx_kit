defmodule Tokumei.Head do
  # TODO test
  defmacro __using__(_opts) do
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
