defmodule Tokumei.CommonLogger do
  @moduledoc """
  Log every request handled by the application.

  Log format is found here: http://httpd.apache.org/docs/1.3/logs.html#common

  """
  defmacro __using__(_opts) do
    quote do
      require Logger
      @before_compile unquote(__MODULE__)
    end
  end
  defmacro __before_compile__(_env) do
    quote do
      defoverridable [handle_request: 2]

      def handle_request(request, config) do
        received_at = DateTime.utc_now
        response = super(request, config)
        case response do
          %{body: _} ->
            responded_at = DateTime.utc_now

            remote_address = "-" # TODO
            remote_user = "-" # TODO
            timestamp = DateTime.to_string(responded_at)
            method = request.method |> to_string
            path = "/" <> (request.path |> Enum.join("/"))
            query = "" # TODO
            version = "HTTP/1.1"
            status = response.status |> to_string

            content_length = case Raxx.ContentLength.fetch(response) do
              {:ok, int} ->
                "#{int}"
              {:error, _} ->
                "-"
            end
            duration = unquote(__MODULE__).duration(received_at, responded_at)
            Logger.debug("#{remote_address} - #{remote_user} [#{timestamp}] \"#{method} #{path}#{query} #{version}\" #{status} #{content_length} #{duration}")
            response
          # TODO handle chunked
          response ->
            response
        end
      end
    end
  end

  def duration(received_at, responded_at) do
    received_at = (DateTime.to_unix(received_at) * 1_000_000) + elem(received_at.microsecond, 0)
    responded_at = (DateTime.to_unix(responded_at) * 1_000_000) + elem(responded_at.microsecond, 0)
    "#{responded_at - received_at}us"
  end
end
