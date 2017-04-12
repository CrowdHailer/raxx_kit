defmodule Tokumei.Patch do
  @moduledoc false
  # Home of functionality that should be contributed to the Raxx project

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
