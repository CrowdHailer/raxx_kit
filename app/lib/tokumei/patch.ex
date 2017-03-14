defmodule Tokumei.Patch do
  @moduledoc """
  Home of functionality that should be contributed to the Raxx project
  """
  def redirect(path) do
    Raxx.Response.found([{"location", path}])
  end

  def request_to_url(%{host: host, port: port, path: path, mount: mount, scheme: scheme}) do
    %URI{
      scheme: scheme,
      host: host,
      port: port,
      path: "/" <> Enum.join(mount ++ path, "/")
    }
    |> URI.to_string()
  end
end
