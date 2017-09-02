defmodule Tokumei.MethodOverride do
  @moduledoc """
  Deprecated temporarily while migrating to raxx streaming.

  Allows browser submitted forms to use HTTP verbs other than `POST`.

  Only the `POST` method can be overridden,
  It can be overridden to use any of these HTTP verbs.
  - `PUT`
  - `PATCH`
  - `DELETE`

  Override target is read from query parameters

  ## Examples

      # override POST to PUT from query value
      iex> post({"/", %{"_method" => "PUT"}})
      ...> |> override_method()
      ...> |> Map.get(:method)
      :PUT

      # override POST to PATCH from query value
      iex> post({"/", %{"_method" => "PATCH"}})
      ...> |> override_method()
      ...> |> Map.get(:method)
      :PATCH

      # override POST to DELETE from query value
      iex> post({"/", %{"_method" => "DELETE"}})
      ...> |> override_method()
      ...> |> Map.get(:method)
      :DELETE

      # overridding method removes the _method field from the query
      iex> post({"/", %{"_method" => "PUT"}})
      ...> |> override_method()
      ...> |> Map.get(:query)
      %{}

      # override works with lowercase query value
      iex> post({"/", %{"_method" => "delete"}})
      ...> |> override_method()
      ...> |> Map.get(:method)
      :DELETE

      # # at the moment breaks deleberatly due to unknown method
      # # does not allow unknown methods
      # iex> post({"/", %{"_method" => "PARTY"}})
      # ...> |> override_method()
      # ...> |> Map.get(:method)
      # :POST

      # leaves non-POST requests unmodified, e.g. GET
      iex> get({"/", %{"_method" => "DELETE"}})
      ...> |> override_method()
      ...> |> Map.get(:method)
      :GET

      # leaves non-POST requests unmodified, e.g. PUT
      # Not entirely sure of the logic here.
      iex> put({"/", %{"_method" => "DELETE"}})
      ...> |> override_method()
      ...> |> Map.get(:method)
      :PUT

      # queries with out a _method field are a no-op
      iex> post({"/", %{"other" => "PUT"}})
      ...> |> override_method()
      ...> |> Map.get(:method)
      :POST

  ## Extensions

  - Should the field be customisable? `_method` as default.*
  - Should it ever error for bad requests.*
  """
  @moduledoc false

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
    raise "Deprecated temporarily while migrating to raxx streaming."
    quote do
      @before_compile unquote(__MODULE__)
    end
  end

  defmacro __before_compile__(_env) do
    quote location: :keep do
      defoverridable [handle_request: 2]

      def handle_request(request, config) do
        request = unquote(__MODULE__).override_method(request)
        super(request, config)
      end
    end
  end
end
