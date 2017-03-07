defmodule Tokumei.Patch do
  @moduledoc """
  Home of functionality that should be contributed to the Raxx project
  """
  def redirect(path) do
    Raxx.Response.found([{"location", path}])
  end
end
