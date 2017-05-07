defmodule Tokumei do
  @moduledoc false
  # Just a aglomoration of other features
  defmacro __using__(_opts) do
    quote do
      use Tokumei.Templates
      use Tokumei.Service

      alias Tokumei.{Flash, Helpers}
      alias Raxx.Response

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
