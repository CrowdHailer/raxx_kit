defmodule Tokumei do
  defmacro __using__(_opts) do
    quote do
      alias Tokumei.ServerSentEvents, as: SSE
      require SSE
      import Tokumei.Config
      use Tokumei.Templates
      import Tokumei.Patch
      use Tokumei.App
      import Raxx.Response

      use Tokumei.NotFound
      use Tokumei.Router
      use Tokumei.ErrorHandler
      use Tokumei.Flash.Query
      # Default content type middleware
      use Tokumei.ContentLength
      use Tokumei.MethodOverride
      use Tokumei.Static
      use Tokumei.Head
      use Tokumei.CommonLogger
    end
  end
end
