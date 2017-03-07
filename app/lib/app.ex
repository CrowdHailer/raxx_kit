defmodule Tokumei do
  defmacro __using__(_opts) do
    quote do
      alias Tokumei.ServerSentEvents, as: SSE
      require SSE
      import Tokumei.Config
      use Tokumei.Templates
      import Tokumei.Patch
      use Tokumei.App

      # Stack in reverse order
      use Tokumei.Routing
      use Tokumei.Exceptions
      use Tokumei.ContentLength
      use Tokumei.CommonLogger
      use Tokumei.MethodOverride
      use Tokumei.Static
    end
  end
  # Build middleware on super
  # static as a proper middleware. will call super if no static files match

  defmacro __before_compile__(_opts) do
    quote do

    end
  end
end
