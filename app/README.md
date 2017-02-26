# Tokumei

**Tiny but MIGHTY Elixir webframework**

```elixir
defmodule MyApp.WWW do
  Use Tokumei

  route "/greeting/:name", {name} do
    get ->
      ok("Hello, #{name}!")
  end
end
```

## Dive in

*Know all about mix and umbrella projects? [Jump onwards to add tokumei in an exitsting project]()*

```
mix archive.install https://github.com/crowdhailer/tokumei/raw/master/tokumei_new.ez
mix tokumei.new my_app
cd my_app
iex -S mix
```

visit [localhost:8080](localhost:8080])

## Usage

### Routing

**N.B. Currently only get() and post() matchers are defined.** See [Development Goals](#development-goals)

```elixir
# Routes are created in blocks grouped by url...
route "/users" do

  # ...and by request method.
  get() ->
    ok("Dan, Lucy, Jane")

  # Methods accept a pattern that will be matched against the request.
  post(%{body: ""}) ->
    bad_request("Please provide a name")

  # Methods can be defined more than once for a multiheaded match.
  post(%{body: name}) ->
    created("Added #{name}")
end

# Any segment beginning with a colon is a path variable.
route "/users/:id", {id} do
  get() ->
    ok("This is user: '#{id}'")
end

# Multiple path variables can be matched.
route "/users/:id/carts/:id", {user_id, cart_id} do
  get() ->
    ok("This is cart: '#{cart_id}' for user: '#{user_id}'")
end

# Server configuration can be accessed from match
route "/users/forgot-password" do
  post(request, %{mailer: mailer}) ->
    mailer.send_password_reset(request.body)
    ok("Reset sent")
end
```

### Responses

```elixir
# An action must return a response with status, body and headers.
route "/" do
  get() ->
    %{status: 200, body: "Home page", headers: [{"content-type", "text/plain"}]}
end

route "/users" do
  get(%{body: data}) ->
    # Helpers available for all response statuses.*(1)
    case MyApp.create_user(data) do
      {:ok, user} ->
        created("New user #{user}")
      {:error, :already_exists} ->
        conflict("sorry")
      {:error, :bad_params} ->
        bad_request("sorry")
      {:error, :database_fail} ->
        bad_gateway("sorry")
      {:error, _unknown} ->
        internal_server_error("Well that's weird")
    end
end
```

*1 - Response helpers are imported from [Raxx.Response](https://hexdocs.pm/raxx/Raxx.Response.html).*

## Development Goals

- [x] Route by url
- [x] Match segements with path variables
- [x] Routing by HTTP method
- [x] Access request in match
- [x] Access server config in match
- [ ] Document chunked/SSE's
- [ ] Document static
- [ ] Document templates
- [ ] Document configuration
- [ ] Add remaining HTTP method matchers.
- [ ] Test routing DSL
- [ ] Add error handling within actions
- [ ] Match on rest of path, "/section/\*rest", I currently have no usecase for this
- [ ] Make server configurable
- [ ] Add mounting of sub-apps
