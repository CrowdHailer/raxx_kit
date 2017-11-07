defmodule Raxx.MethodOverride do
  @moduledoc """
  Allows browser to emulate using HTTP verbs other than `POST`.

  ## Usage

  Add to the module as part of a Raxx server middleware stack.

      defmodule MyApp.WWW do
        use Raxx.Server
        use Raxx.MethodOverride
      end

  Only the `POST` method will be overridden,
  It can be overridden to any of the listed HTTP verbs.
  - `PUT`
  - `PATCH`
  - `DELETE`

  The emulated method is is denoted by the `_method` parameter of the url query.

  ## Examples

      # override POST to PUT from query value
      iex> request(:POST, "/?_method=PUT")
      ...> |> override_method()
      ...> |> Map.get(:method)
      :PUT

      # override POST to PATCH from query value
      iex> request(:POST, "/?_method=PATCH")
      ...> |> override_method()
      ...> |> Map.get(:method)
      :PATCH

      # override POST to DELETE from query value
      iex> request(:POST, "/?_method=DELETE")
      ...> |> override_method()
      ...> |> Map.get(:method)
      :DELETE

      # overridding method removes the _method field from the query
      iex> request(:POST, "/?_method=PUT")
      ...> |> override_method()
      ...> |> Map.get(:query)
      %{}

      # override works with lowercase query value
      iex> request(:POST, "/?_method=delete")
      ...> |> override_method()
      ...> |> Map.get(:method)
      :DELETE

      # # at the moment breaks deleberatly due to unknown method
      # # does not allow unknown methods
      # iex> request(:POST, "/?_method=PARTY")
      # ...> |> override_method()
      # ...> |> Map.get(:method)
      # :POST

      # leaves non-POST requests unmodified, e.g. GET
      iex> request(:GET, "/?_method=DELETE")
      ...> |> override_method()
      ...> |> Map.get(:method)
      :GET

      # leaves non-POST requests unmodified, e.g. PUT
      # Not entirely sure of the logic here.
      iex> request(:PUT, "/?_method=DELETE")
      ...> |> override_method()
      ...> |> Map.get(:method)
      :PUT

      # queries with out a _method field are a no-op
      iex> request(:POST, "/?other=PUT")
      ...> |> override_method()
      ...> |> Map.get(:method)
      :POST
  """

  @doc """
  Modify a requests method based on query parameters
  """
  def override_method(request = %{method: :POST, query: query}) do
    {method, query} = Map.pop(query, "_method")
    case method && String.upcase(method) do
      nil ->
        request
      method when method in ["PUT", "PATCH", "DELETE"] ->
        method = String.to_existing_atom(method)
        %{request | method: method, query: query}
    end
  end
  def override_method(request) do
    request
  end

  defmacro __using__(_opts) do
    quote do
      @before_compile unquote(__MODULE__)
    end
  end

  defmacro __before_compile__(_env) do
    quote location: :keep do

      defoverridable Raxx.Server

      @impl Raxx.Server
      def handle_head(request, state) do
        request = unquote(__MODULE__).override_method(request)
        super(request, config)
      end
    end
  end
end
