defmodule Tokumei.Config do
  @moduledoc false
  # This module is effectivly deprecated until futher notice
  # config(:basic_auth, :whitelist, ["/"])
  # @basic_auth_config, %{@basic_auth_config | whitelist: value}

  defmacro config(:port, port) do
    quote do
      @port unquote(port)
    end
  end
  defmacro config(:static, port) do
    quote do
      @static unquote(port)
    end
  end
  defmacro config(:templates, port) do
    quote do
      @templates unquote(port)
    end
  end
end
