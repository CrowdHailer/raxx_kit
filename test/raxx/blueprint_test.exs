defmodule Raxx.BlueprintTest.Root do
  use Raxx.Server

  @impl Raxx.Server
  def handle_request(_, _), do: {[], :state}
end
defmodule Raxx.BlueprintTest.AlternativeMethod do
  use Raxx.Server

  @impl Raxx.Server
  def handle_request(_, _), do: {[], :state}
end
defmodule Raxx.BlueprintTest.GetAStaticResource do
  use Raxx.Server

  @impl Raxx.Server
  def handle_request(_, _), do: {[], :state}
end
defmodule Raxx.BlueprintTest.GetAParameterizedResource do
  use Raxx.Server

  @impl Raxx.Server
  def handle_request(_, _), do: {[], :state}
end
defmodule Raxx.BlueprintTest do
  use ExUnit.Case

  use Raxx.Server
  use Raxx.Blueprint, "./blueprint_test.apib"


  test "get root" do
    request = Raxx.request(:GET, "/")
    assert {[], {Raxx.BlueprintTest.Root, :state}} ==  __MODULE__.handle_head(request, [])
  end

  test "request with alternative method" do
    request = Raxx.request(:POST, "/")
    assert {[], {Raxx.BlueprintTest.AlternativeMethod, :state}} ==  __MODULE__.handle_head(request, [])
  end

  test "get a static resource" do
    request = Raxx.request(:GET, "/resources")
    assert {[], {Raxx.BlueprintTest.GetAStaticResource, :state}} ==  __MODULE__.handle_head(request, [])
  end

  test "get a parameterized resource" do
    request = Raxx.request(:GET, "/resources/1234")
    assert {[], {Raxx.BlueprintTest.GetAParameterizedResource, :state}} ==  __MODULE__.handle_head(request, [])
  end
end
