defmodule Tokumei.NotFound do
  @moduledoc """
  Return a not found exception in response to any request.

  All functionallity in Tokumei is build as middleware, including `Tokumei.Router`.
  Middleware expect `handle_request/2` to already be defined
  This module defines `handle_request/2` to base a middleware stack on.
  """
  defmacro __using__(_opts) do
    quote do
      @before_compile unquote(__MODULE__)
    end
  end

  defmacro __before_compile__(_env) do
    quote do
      def handle_request(%{path: path}, _) do
        {:error, %Tokumei.Exception.NotFoundError{path: path}}
      end
    end
  end
end
