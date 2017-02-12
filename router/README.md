# Tokumei.Router

**Focused routing layer for Raxx applications**

1. DSL for routing incomming HTTP requests by path and method.
2. Extension to the Raxx interface to provide better error handling.
3. Concept of a middleware stack.

## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed as:

  1. Add `tokumei_router` to your list of dependencies in `mix.exs`:

    ```elixir
    def deps do
      [
        {:tokumei_router, "~> 0.3.0"},
        {:ace_http, "~> 0.1.2"}
      ]
    end
    ```

  2. Ensure `tokumei_router` is started before your application:

    ```elixir
    def application do
      [applications: [:tokumei_router, :ace_http]]
    end
    ```

*Ace.HTTP is a server that can host Raxx applications,
  adapters are also available for [cowboy](https://hex.pm/packages/raxx_cowboy) and [elli](https://hex.pm/packages/raxx_elli).*

## Usage

```elixir
# my_app/router.ex

defmodule MyApp.Router do
  use Tokumei.Router
  alias Raxx.Response

  # use middleware by specifying module and configuration.
  # ContentLength is included as an example.
  @middleware {Tokumei.Router.ContentLength, nil}

  # Define response actions inline using Raxx Helpers.
  route "/hello" do
    :GET -> Response.ok("Hello, World!")
  end

  # Match on string variables
  route "/hello/:name" do
    :GET ->
      greeting = "Hello, #{name}!"
      Response.ok(greeting)
  end

  # Define actions for multiple methods on a resource.
  route "/users/:id" do
    :GET -> UsersController.show(id, request)
    :POST -> UsersController.create(id, request)
    :DELETE -> UsersController.delete(id, request)
  end

  # Access the request and environment passed to the router
  route "/users" do
    :GET ->
      %{page: page_number} = request.query
      users_page = env.user_repo.all(page_number: page_number)
      Response.ok(users_page)
  end

  # Handle routing errors
  error %NotFoundError{request: request} do
    Response.not_found("not found: #{inspect(request.path)}")
  end

  error %MethodNotAllowedError{allowed: allowed} do
    Raxx.Response.method_not_allowed([{"allow", allowed |> Enum.join(" ")}])
  end

  # return custom errors
  route "/sign-up" do
    :POST ->
      case validate_sign_up_form(request.body) do
        {:ok, data} ->
          Response.created()
          # continue
        {:error, _reason} ->
          {:error, :bad_request}
      end
  end

  error :bad_request do
    Response.bad_request()
  end

  # Mount subapp
  mount "/api", APIRouter
end
```

Choose a server to host the application.
Using `Tokumei.Router` will create a Raxx App that can be mounted using any of the adapters found in [Raxx](https://github.com/CrowdHailer/raxx)

```elixir
defmodule MyApp do
  use Application

  def start(_type, _args) do
    import Supervisor.Spec, warn: false

    children = [
      worker(Ace.HTTP, [{MyApp.Router, []}, [port: 8080]])
    ]

    opts = [strategy: :one_for_one]
    Supervisor.start_link(children, opts)
  end
end
```

The `Tokumei.Router` provides a simple routing DSL that first routes on path and second on request method.
This is done so that `Tokumei.Router` can return the correct responses for resources that will respond to only a subset of HTTP verbs.

```elixir
import Raxx.Request

assert 200 == MyApp.Router.handle_request(get("/hello"), :env)
assert 405 == MyApp.Router.handle_request(put("/hello"), :env)
assert 404 == MyApp.Router.handle_request(put("/random"), :env)
```
