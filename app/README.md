# Tokumei

**Tiny but MIGHTY Elixir webframework**

```elixir
defmodule MyApp.WWW do
  Use Tokumei

  route "/greeting/:name", {name} do
    get(_request, _config) ->
      ok("Hello, #{name}!")
  end
end
```

## Dive in

<!-- *Know all about mix and umbrella projects? [Jump onwards to add tokumei in an exitsting project]()* -->

```
mix archive.install https://github.com/crowdhailer/tokumei/raw/master/tokumei_new.ez
mix tokumei.new my_app
cd my_app
iex -S mix
```

visit [localhost:8080](localhost:8080])

## Usage

### Routing

```elixir
# Routes are created in blocks grouped by url...
route "/users" do

  # ...and by request method.
  get(_) ->
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
  get(_) ->
    ok("This is user: '#{id}'")
end

# Multiple path variables can be matched.
route "/users/:id/carts/:id", {user_id, cart_id} do
  get(_) ->
    ok("This is cart: '#{cart_id}' for user: '#{user_id}'")
end

# Server configuration can be accessed from match.
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
  get(_) ->
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

### Streaming

```elixir
route "/updates" do
  get(_) ->

    # Return a streaming upgrade to change a server state to streaming.
    SSE.stream()
end

# Define behaviour for a server that has transitioned to streaming.
SSE.streaming do

  # match on messages received by server.
  {:update, update} ->
    {:send, update}
end
```

### Static content

```elixir
# Serve the contents of a directory, file path is relative to this file.
config :static, "./public"
```

*- Files are served using [Raxx.Static](https://hex.pm/packages/raxx_static)*

### Templates

```elixir
# relative path to template ./templates/home_page.html.eex
# relative path to template ./templates/user_page.html.eex

# Provide a relative path to templates directory.
config :templates, "./templates"

route "/" do
  get(_) ->

    # View functions are compiled for each template.
    ok(home_page())
end

route "/users/:id", {id} do
  get(_) ->
    user = UsersRepo.fetch_by_id(id)

    # Variable are passed accessed in template as, `@user`.
    ok(user_page(%{user: user}))
end
```

*- Templates must have an eex extension*

*- Content type is derived from first pary of template extension.*

### Error Handling

```elixir
route "/checkout" do
  post(request) ->

    # Actions can return an exception as part of an error tuple
    {:error, :subscription_expired}
end

# Any error can be handled using an error block
error :subscription_expired do

  # payment_required/1 returns a 402 status Raxx.Response
  payment_required("Please pay up, :-)")
end

# Routing errors can also be intercepted
error %NotFoundError{path: path} do
  path = "/" <> Enum.join(path, "/")

  # For example, to send a custom response message.
  not_found("Could not find #{path}")
end
```

### Server state

TODO

### Request

```elixir
route "/" do
  get(request) ->
    IO.inspect(request.scheme)  # "http"
    IO.inspect(request.host)    # "www.exxample.com"
    IO.inspect(request.port)    # 8080
    IO.inspect(request.method)  # :GET
    IO.inspect(request.mount)   # []
    IO.inspect(request.path)    # []
    IO.inspect(request.query)   # %{"page" => "5"}
    IO.inspect(request.headers) # [{"accept", "text/html"}]
    IO.inspect(request.body)    # "Lorem ..."
end
```

### Model

**Tokumei is a XVC framework.**

Routing is provided for controllers, and templating for views.
Applications bring their own model.

### Testing

TODO - same as Raxx

## Development Goals

- [x] Route by url
- [x] Match segements with path variables
- [x] Routing by HTTP method
- [x] Access request in match
- [x] Access server config in match
- [x] Document chunked/SSE's
- [x] Document static
- [x] Document templates
- [x] Add remaining HTTP method matchers.
- [x] Test routing DSL
- [x] Add error handling within actions
- [x] Add logging layer

- [ ] named routes
- [ ] mix task to list all routes in a module `tokumei.routes MyApp.WWW`

      "/", GET, HEAD
      "/users", GET, HEAD, POST
      "/users/:id", GET, HEAD, PATCH, DELETE
- [ ] Draft designing a DSL

- [ ] chunked responses
- [ ] Test streaming
- [ ] Handle messages to server without sending a chunk

- [ ] mod docs routing
- [ ] mod docs streaming
- [ ] all middleware mod docs
- [ ] publish why raxx article
- [ ] write overview article
- [ ] publish build your own middleware article

- [ ] Make server configurable
- [ ] Extract starting as application from starting as supervised process

- [ ] HTTPS setup with lets encrypt
- [ ] article Setting up without generator

- [ ] Deployment examples. Digital Ocean, Vagrant, Kuberneties
- [ ] Add wobserver

- [ ] Handle Server Errors, url too long, request too slow, request too large

- [ ] remove redirect from patch
- [ ] back(request) -> response

- [ ] Add mounting of sub-apps

      ```elixir
      mount "/api", {request, config} do
        # request is using mount value

        # To controller
        ApiRouter.handle_request(request, config)

        # To service
        request = %{request | mount: [], host: "api.dmz"} # De militarized zone, i.e. private
        make_request(request)
      end
      ```

- [ ] Consider a Controller architecture for larger projects

      ```elixir
      route "/" do
        get(WelcomeController, :home)
        post(WelcomeController, :enquiry)
      end

      @route_name :home # path(:home) -> "/", url(:home, request) -> "www.example.com/"
      route "/",
        GET: HomePage,
        POST: SendEnquiry

      @route_name :home # path(:home) -> "/", url(:home, request) -> "www.example.com/"
      route "/", {request, config} do
        :GET -> HomePage.handle_request(request, config),
        :POST -> SendEnquiry.handle_request(request, config)
      end
      ```
- [ ] Cookies, Sessions and Flash

- [ ] Consider before and after filters, implemented as a raxx middleware

      ```elixir
      before request, config do
        request # OR {:error, reason}
      end

    after response, config do
        request # OR {:error, reason}
      end
      ```
- [ ] Sending files from action https://github.com/sinatra/sinatra/blob/master/lib/sinatra/base.rb#L384
- [ ] Send file middleware, a return value of {:file, path} -> response
- [ ] Send content as an attachment https://github.com/sinatra/sinatra/blob/master/lib/sinatra/base.rb#L373

- [ ] HTTP/2 promises API, integration with raxx_chatterbox
- [ ] layout and partials
- [ ] Code reloading
- [ ] Example with JS compilation, add to generator

- [ ] Generate sitemap.xml from router
- [ ] Basic Auth wrapper, with whitelist
