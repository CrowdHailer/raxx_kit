defmodule Tokumei.Flash do
  @moduledoc """
  Notifications to show on the next request, after redirection

      # In a login action
      response = found()
      |> Location.set("/my-account")
      |> Flash.write(success: "Welcome back.")

      # After being redirected to `/my-account`
      [success: "Welcome back."] = Flash.read(request)

  Multiple flash messages can be written,
  `read` will always return a list of messages.

  Flash messages are the combination of tag and content.
  Default tags are:

  - `danger` - e.g. Account has expired
  - `warning` - e.g. Username required for signup
  - `success` - e.g. Email was updated
  - `info` - e.g. Anything else

  The `Flash` module defines working with flash messages.
  A specific transfer mechanism must be selected for flash messages.

  `Tokumei.Flash.Query` is the default flash transfer mechanism.

  ## Examples

      # Flash messages will be added to response headers
      iex> Response.see_other()
      ...> |> Flash.write(danger: "Bad times :-0")
      ...> |> Map.get(:headers)
      [{"tokumei-flash", {:danger, "Bad times :-0"}}]

      # Multiple flash messages can be added
      iex> Response.see_other()
      ...> |> Flash.write(success: "Good news first.")
      ...> |> Flash.write(warning: "But also...")
      ...> |> Map.get(:headers)
      [
        {"tokumei-flash", {:success, "Good news first."}},
        {"tokumei-flash", {:warning, "But also..."}}]

      # Flash messages can be read off a request
      iex> Request.get("/", [{"tokumei-flash", {:danger, "Bad times :-0"}}])
      ...> |> Flash.read()
      [danger: "Bad times :-0"]

  ## Extensions

  - Configurable list of known tags.
  - Log warnings when writing to a message that is not a redirect.
  - Configurable header name.
  """
  @moduledoc false

  @tags [:danger, :warning, :success, :info]
  @header_name "tokumei-flash"

  @doc """
  Write new flash messages to a response.
  """
  def write(response = %{headers: headers}, messages) do
    flash_headers = Enum.map(messages, &to_flash_headers/1)
    extended_headers = headers ++ flash_headers
    %{response | headers: extended_headers}
  end

  @doc """
  Read all flash messages from a request.
  """
  def read(%{headers: headers}) do
    :proplists.get_all_values(@header_name, headers)
  end

  @doc """
  Remove all flash messages set on a request/response.
  """
  def clear(r = %{headers: headers}) do
    headers = :proplists.delete(@header_name, headers)
    %{r | headers: headers}
  end

  defp to_flash_headers({tag, content}) when tag in @tags do
    {@header_name, {tag, content}}
  end
end
