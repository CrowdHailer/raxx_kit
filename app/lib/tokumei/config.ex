defmodule Tokumei.Config do

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
