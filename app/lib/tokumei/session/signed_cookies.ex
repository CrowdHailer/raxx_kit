defmodule Tokumei.Session.SignedCookies do
  @moduledoc """
  Cookie based session storage.

  `Tokumei.Session.SignedCookies` can be added as a middleware.

  A session is a map of binary keys and values.
  A session added to a response under the `tokumei-session` header will be sent to the client.
  A valid session sent from the client is added to the request under the `tokumei-session` header.


      defmodule MyApp do
        use Tokumei.NotFound
        use Tokumei.Router
        import Raxx.Response
        use Tokumei.Session.SignedCookies

        @secret "eggplant"

        route ["session", first_value] do
          :PUT ->
            new_session = %{"first" => first_value}
            ok("Session set", [{"tokumei-session", new_session}])
        end

        route ["session", first_value, second_value] do
          :PUT ->
            new_session = %{"first" => first_value, "second" => second_value}
            ok("Session set", [{"tokumei-session", new_session}])
        end

        route ["session"], request do
          :GET ->
            session = :proplists.get_value("tokumei-session", request.headers)
            value = Map.get(session, "first", "none-set")
            ok("Session value: \#{value}")
          :DELETE ->
            new_session = %{}
            ok("Session set", [{"tokumei-session", new_session}])
        end
      end

  Responses will have any session data that is set serialized into cookies.
  Requests will have their session (if any) rebuilt from the cookies they send.

  An additional cookie (`tokumei.session`) is set to validate the integrity of sessions.

  *N.B. Stored session data can be viewed by the client.*

  There are also limitations to the number and size of cookies that a browser will persist.

  *ALSO*, should cookie attribute be captialized Path=/ or path=/
  """

  defmodule UnspecifiedSecretError do
    defexception message: "A `:secret` must be set for signing cookies."
  end

  defmacro __using__(_opts) do
    quote do
      @before_compile unquote(__MODULE__)
      @secret nil
    end
  end

  # In development it will show warnings for tampered cookies.
  defmacro __before_compile__(_env) do
    quote location: :keep do
      defoverridable [handle_request: 2]

      def handle_request(request = %{headers: headers}, config) do
        session = unquote(__MODULE__).extract(request, secret: @secret)
        headers = headers ++ [{"tokumei-session", session}]
        set_keys = Map.keys(session)
        response = super(%{request | headers: headers}, config)
        case :proplists.get_all_values("tokumei-session", response.headers) do
          [session] ->
            if session == %{} do
              unquote(__MODULE__).delete(response, set_keys, secret: @secret)
            else
              new_keys = Map.keys(session)
              delete_headers = Enum.reject(set_keys, fn(k) -> Enum.member?(new_keys, k) end)
              |> Enum.map(&unquote(__MODULE__).expire_header/1)
              response = %{response | headers: response.headers ++ delete_headers}
              unquote(__MODULE__).embed(response, session, secret: @secret)
            end
          [] ->
            response
        end
      end
    end
  end

  @cookie_name "tokumei.session"

  # Test deletes all cookies
  @doc """
  Extract session from signed cookie values.

  ## Examples

      # Sessions will be extracted from cookies
      iex> Request.get("/", [
      ...>   {"cookie", "foo=bar"},
      ...>   {"cookie", "tokumei.session=foo -- yjdW%2BB03KKAjvcimIsCQbzc7eV4%3D"}])
      ...> |> SignedCookies.extract(secret: "secret")
      %{"foo" => "bar"}

      # Extra cookies are discarded
      iex> Request.get("/", [
      ...>   {"cookie", "foo=bar"},
      ...>   {"cookie", "stealthy=value"},
      ...>   {"cookie", "tokumei.session=foo -- yjdW%2BB03KKAjvcimIsCQbzc7eV4%3D"}])
      ...> |> SignedCookies.extract(secret: "secret")
      %{"foo" => "bar"}

      # Missing value will result in no session
      iex> Request.get("/", [
      ...>   {"cookie", "tokumei.session=foo -- yjdW%2BB03KKAjvcimIsCQbzc7eV4%3D"}])
      ...> |> SignedCookies.extract(secret: "secret")
      %{}
      # Extend {:error, {:missing_keys: ["foo"]}}

      # Tampered values will return empty session
      iex> Request.get("/", [
      ...>   {"cookie", "foo=BAD"},
      ...>   {"cookie", "tokumei.session=foo -- yjdW%2BB03KKAjvcimIsCQbzc7eV4%3D"}])
      ...> |> SignedCookies.extract(secret: "secret")
      %{}
      # Extend {:error, :signature_does_not_match}

      # Invalid session cookie will return empty session
      iex> Request.get("/", [
      ...>   {"cookie", "foo=bar"},
      ...>   {"cookie", "tokumei.session=garbage"}])
      ...> |> SignedCookies.extract(secret: "secret")
      %{}
      # Extend {:error, :invalid_session_hallmark}

      # Sessions will be extracted from cookies
      iex> Request.get("/", [
      ...>   {"cookie", "foo=bar"}])
      ...> |> SignedCookies.extract(secret: "secret")
      %{}
      # Extend {:error, :no_session_hallmark}
  """
  def extract(request, opts) do
    {:ok, secret} = Keyword.fetch(opts, :secret)
    cookies = :proplists.get_all_values("cookie", request.headers)
    |> Enum.map(fn(cookie_string) ->
      Cookie.parse(cookie_string)
    end)
    |> Enum.reduce(%{}, fn(i, acc) -> Map.merge(acc, i) end)

    case Map.fetch(cookies, @cookie_name) do
      :error ->
        %{}
      {:ok, hallmark} ->
        case String.split(hallmark, " -- ") do
          [keys_string, signature] ->
            keys = String.split(keys_string, " ")
            signing_string = keys
            |> Enum.map(fn(k) -> Map.get(cookies, k) end)
            |> Enum.join

            case create_digest(signing_string, secret) do
              ^signature ->
                Enum.map(keys, fn(k) -> {k, Map.get(cookies, k)} end)
                |> Enum.into(%{})
              _ ->
                %{}
            end
          _ ->
            %{}
        end
    end
  end

  @doc """
  Set cookies for a sessions contents

  ## Examples

      # Each key value from a session is set as a cookie
      iex> Response.ok()
      ...> |> SignedCookies.embed(%{"foo" => "bar"}, secret: "secret")
      ...> |> Map.get(:headers)
      ...> |> List.first
      {"set-cookie", "foo=bar; path=/; HttpOnly"}

      # A signature is set as a final cookie
      iex> Response.ok()
      ...> |> SignedCookies.embed(%{"foo" => "bar"}, secret: "secret")
      ...> |> Map.get(:headers)
      ...> |> List.last
      {"set-cookie",
        "tokumei.session=foo -- yjdW%2BB03KKAjvcimIsCQbzc7eV4%3D; path=/; HttpOnly"}
  """
  def embed(response = %{headers: headers}, session, opts) do
    secret = case Keyword.get(opts, :secret) do
      secret when is_binary(secret) ->
        secret
      nil ->
        raise UnspecifiedSecretError
    end

    keys = Map.keys(session)

    signature = keys
    |> Enum.map(fn(key) -> session[key] end)
    |> Enum.join("")
    |> create_digest(secret)

    hallmark = Enum.join(keys, " ") <> " -- " <> signature

    session_cookie = SetCookie.serialize("tokumei.session", hallmark)

    cookie_headers = Enum.map(session, fn({key, value}) ->
      {"set-cookie", SetCookie.serialize(key, value)}
    end) ++ [{"set-cookie", session_cookie}]
    %{response | headers: headers ++ cookie_headers}
  end


  @doc """
  Expire the session.

  Expires a session by resetting the validation cookie with a past expiry date.
  A list of keys will also be expired, to remove any user preferences from the browser.

      # Expire the signature cookie.
      iex> Response.ok()
      ...> |> SignedCookies.delete([], [])
      ...> |> Map.get(:headers)
      ...> |> List.last()
      {"set-cookie",
        "tokumei.session=; path=/; expires=Thu, 01 Jan 1970 00:00:00 GMT; max-age=0; HttpOnly"}

      # Expire the cookie for each key.
      iex> Response.ok()
      ...> |> SignedCookies.delete(["foo"], [])
      ...> |> Map.get(:headers)
      ...> |> List.first()
      {"set-cookie",
        "foo=; path=/; expires=Thu, 01 Jan 1970 00:00:00 GMT; max-age=0; HttpOnly"}

  """
  def delete(response = %{headers: headers}, keys, _opts) do
    headers = :proplists.delete("tokumei-session", headers)
    cookie_headers = keys ++ ["tokumei.session"]
    |> Enum.map(&expire_header/1)
    %{response | headers: headers ++ cookie_headers}
  end

  @doc false
  def expire_header(key) do
    {"set-cookie", SetCookie.expire(key)}
  end

  defp create_digest(signing_string, secret) do
    :crypto.hmac(:sha, secret, signing_string)
    |> Base.encode64
    |> URI.encode_www_form
  end
end
