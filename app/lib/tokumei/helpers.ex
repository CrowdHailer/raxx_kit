defmodule Tokumei.Helpers do
  @moduledoc """
  Selection of utilities.
  """

  @doc """
  Redirect a request

  ## Examples

      # redirects back to referrer if provided
      iex> Request.get("/", [{"referer", "/foo"}])
      ...> |> Helpers.back("/bar")
      ...> |> Map.get(:headers)
      [{"location", "/foo"}]

      # redirects to default path if none provided
      iex> Request.get("/")
      ...> |> Helpers.back("/bar")
      ...> |> Map.get(:headers)
      [{"location", "/bar"}]

      # redirect is see other by default
      iex> Request.get("/")
      ...> |> Helpers.back("/bar")
      ...> |> Map.get(:status)
      303

  """
  def back(request, default) do
    # DEBT would like to use `Raxx.Referrer.get(request, default)`
    case Raxx.Referrer.fetch(request) do
      {:ok, referrer} ->
        # DEBT would like to be able to pass URI as needed
        "#{referrer}"
      {:error, _} ->
        default
    end
    |> redirect()
  end

  @doc """
  Create a response directing the client to a new location

  ## Examples

      # Returns status 303 when only path given
      iex> Helpers.redirect("/foo").status
      303

      # Location is set as redirected path
      iex> Helpers.redirect("/foo").headers
      [{"location", "/foo"}]

      # Status can be passed as the second argument
      iex> Helpers.redirect("/foo", 301).status
      301

      # Redirection can include a query
      iex> Helpers.redirect({"/", %{key: "value"}}).headers
      [{"location", "/?key=value"}]

      # Redirection will set body including escaped url
      iex> Helpers.redirect({"/", %{a: "b", c: "d"}}).body
      ...> |> String.contains?("/?a=b&amp;c=d")
      true

      # Body can be overwritten by passing string as second argument
      iex> Helpers.redirect("/", "Not here!").body
      "Not here!"

      # Body can be overwritten by passing io_list as second argument
      iex> Helpers.redirect("/", ["Not here", "!"]).body
      ["Not here", "!"]

  ## Notes

  - 303 Instructs a client to make a `GET` request to the new location
  - 303 status was added to HTTP/1.1,
    if a client makes a HTTP/1.0 request then a 303 status should be rewritten to 302
  - Could have `redirect/2,3` always take a request to generate absolute URI
  - And have separate `redirect_external/1,2`
  - Middleware could write relative redirects if required.
  - Optionally extend routers to make a redirect helper that takes a resource/locale
    `MyApp.redirect(request, {:user, 24}, 301)`
  - Link to sinatra test for proxy logic https://github.com/sinatra/sinatra/blob/9bd0d40229f76ff60d81c01ad2f4b1a8e6f31e05/test/helpers_test.rb#L183
  """
  def redirect(location, details \\ %{})
  def redirect(location, status) when is_integer(status) do
    redirect(location, %{status: status})
  end
  def redirect(location, details = %{}) do
    status = Map.get(details, :status, 303)
    location = validate_location(location)
    body = Map.get(details, :body, redirect_page(location))
    %Raxx.Response{
      status: status,
      headers: [{"location", location}],
      body: body
    }
  end
  def redirect(location, body) do
    redirect(location, %{body: body})
  end

  defp validate_location(location) when is_binary(location) do
    location
  end
  defp validate_location({path, query}) when is_binary(path) do
    path <> "?" <> Plug.Conn.Query.encode(query)
  end

  defp redirect_page(url) do
    html = Plug.HTML.html_escape(url)
    "<html><body>This resource has moved <a href=\"#{html}\">here</a>.</body></html>"
  end
end
