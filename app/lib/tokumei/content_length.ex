defmodule Tokumei.ContentLength do
  defmacro __using__(_opts) do
    quote do
      defoverridable [handle_request: 2]

      def handle_request(request, env) do
        response = super(request, env)
        case response do
          %{body: _} -> # I am a response
            response = case Raxx.ContentLength.fetch(response) do
              {:ok, _} ->
                response
              {:error, :field_value_not_specified} ->
                Raxx.ContentLength.set(response, :erlang.iolist_size(response.body))
            end
          upgrade = %Raxx.Chunked{} ->
            upgrade
        end
      end

      @before_compile unquote(__MODULE__)
    end
  end

  defmacro __before_compile__(_env) do
    quote do

    end
  end
end
