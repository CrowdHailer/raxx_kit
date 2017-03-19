defmodule Tokumei.Flash.Query do
  @moduledoc """
  Store flash messages as part of a url's query.

  See `Tokumei.Flash` for documentation on reading and writing flash messages.

  `Tokumei.Flash.Query` can be added as a middleware.

      defmodule MyApp do
        use #{__MODULE__}
      end

  Inbound messages will automatically be extracted from request queries.
  Outbound messages will be embedded in the response location.

  *N.B. A location header must be on a response to embed flash messages.*
  """

  defmodule NoLocationError do
    defexception message: "A `location` header must be set, to embed flash messages with #{__MODULE__}"
  end

  defmacro __using__(_opts) do
    quote do
      @before_compile unquote(__MODULE__)
    end
  end

  defmacro __before_compile__(_env) do
    quote do
      defoverridable [handle_request: 2]
      def handle_request(request, config) do
        {messages, request} = unquote(__MODULE__).extract(request)
        request = Tokumei.Flash.write(request, messages)
        response = super(request, config)

        messages = Tokumei.Flash.read(response)
        response = Tokumei.Flash.clear(response)
        unquote(__MODULE__).embed(response, messages)
      end
    end
  end

  @query_key "_flash"

  @doc """
  Extract all query transfered flash messages from a request

  ## Examples

      # Flash messages are extracted from query
      iex> Request.get("/?_flash[]=danger%3ABad+times&_flash[]=success%3AHooray")
      ...> |> Flash.Query.extract()
      ...> |> elem(0)
      [danger: "Bad times", success: "Hooray"]

      # Request is returned with flash removed
      iex> Request.get("/?_flash[]=danger%3Amessage+here&foo=bar")
      ...> |> Flash.Query.extract()
      ...> |> elem(1)
      ...> |> Map.get(:query)
      %{"foo" => "bar"}

      # Single message is returned as a list
      iex> Request.get("/?_flash=info%3ABeeTeeDubs")
      ...> |> Flash.Query.extract()
      ...> |> elem(0)
      [info: "BeeTeeDubs"]

      # Empty list is returned if no query
      iex> Request.get("/")
      ...> |> Flash.Query.extract()
      ...> |> elem(0)
      []

      # query parameter to use for flash can be configured
      iex> Request.get("/?_notices[]=info%3AOla")
      ...> |> Flash.Query.extract(key: "_notices")
      ...> |> elem(0)
      [info: "Ola"]

  """
  def extract(request = %{query: query}, opts \\ []) do
    key = Keyword.get(opts, :key, @query_key)
    {serialized_messages, clean_query} = Map.pop(query, key, [])
    messages = Enum.map(List.wrap(serialized_messages), &parse_message/1)
    {messages, %{request | query: clean_query}}
  end

  defp parse_message("danger:" <> content), do: {:danger, content}
  defp parse_message("warning:" <> content), do: {:warning, content}
  defp parse_message("success:" <> content), do: {:success, content}
  defp parse_message("info:" <> content), do: {:info, content}

  @doc """
  Embed messages within a redirection query

  ## Examples

      # Flash message will be embedded in query
      iex> {:ok, %{query: query}} = Response.see_other()
      ...> |> Raxx.Location.set("/")
      ...> |> Flash.Query.embed(warning: "Hold it")
      ...> |> Raxx.Location.fetch()
      ...> query
      "_flash%5B%5D=warning%3AHold+it"

      iex> {:ok, %{query: query}} = Response.see_other()
      ...> |> Raxx.Location.set("/")
      ...> |> Flash.Query.embed(warning: "Hold it", info: "It's Sunday")
      ...> |> Raxx.Location.fetch()
      ...> query
      "_flash%5B%5D=warning%3AHold+it&_flash%5B%5D=info%3AIt%27s+Sunday"

      # Flash messages can be embedded under custom key
      iex> {:ok, %{query: query}} = Response.see_other()
      ...> |> Raxx.Location.set("/")
      ...> |> Flash.Query.embed([warning: "Hold it"], key: "_notices")
      ...> |> Raxx.Location.fetch()
      ...> query
      "_notices%5B%5D=warning%3AHold+it"

      # Flash messages are dropped if embed is silent and no location is provided.
      iex> response = Response.see_other()
      ...> response == Flash.Query.embed(response, [warning: "Hold it"], silent: true)
      true

      # Flash messages are dropped if embed is silent and no location is provided.
      iex> response = Response.see_other()
      ...> try do
      ...>   Flash.Query.embed(response, [warning: "Hold it"])
      ...> rescue
      ...>   e -> e
      ...> end
      %Flash.Query.NoLocationError{}
  """
  def embed(response, messages, opts \\ [])
  def embed(response, [], _opts) do
    response
  end
  def embed(response, messages, opts) do
    key = Keyword.get(opts, :key, @query_key)
    silent? = Keyword.get(opts, :silent, false)
    case Raxx.Location.fetch(response) do
      {:error, :field_value_not_specified} when silent? ->
        response
      {:error, :field_value_not_specified} ->
        raise NoLocationError
      {:ok, uri = %{query: query}} ->
        serialized_messages = Enum.map(messages, &serialize_message/1)
        extended_query = Enum.reduce(serialized_messages, query, fn
          (msg, nil) ->
            URI.encode_query(%{"#{key}[]" => msg})
          (msg, q) ->
            q <> "&" <> URI.encode_query(%{"#{key}[]" => msg})
        end)
        Raxx.Location.set(response, %{uri | query: extended_query})
    end
  end

  defp serialize_message({:danger, content}), do: "danger:" <> content
  defp serialize_message({:warning, content}), do: "warning:" <> content
  defp serialize_message({:success, content}), do: "success:" <> content
  defp serialize_message({:info, content}), do: "info:" <> content
end
