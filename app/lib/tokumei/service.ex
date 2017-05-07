defmodule Tokumei.Service do
  defmacro __using__(_opts) do
    if !Code.ensure_loaded?(Ace.HTTP) do
      raise """
      No supported server is loaded in #{Mix.env} mode. Check mix file, e.g.

          {:ace, "~> 0.9.0"}
      """
    end

    quote do
      def start_link(options) do
        start_link(nil, options)
      end

      def start_link(config, options) do
        app = {__MODULE__, config}
        case Keyword.get(options, :tls) do
          nil ->
            Ace.HTTP.start_link(app, options)
          tls_options when is_list(tls_options) ->
            Ace.HTTPS.start_link(app, options ++ tls_options)
        end
      end
    end
  end
end
