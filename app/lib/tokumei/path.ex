defmodule Tokumei.Path do
  @moduledoc false

  defmacro to(path) do
    quote do
      Path.expand(unquote(path), Path.dirname(__ENV__.file))
    end
  end
end
