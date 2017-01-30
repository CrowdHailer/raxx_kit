# Tokumei.Router

**Routing layer for Raxx applications**

## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed as:

  1. Add `tokumei_router` to your list of dependencies in `mix.exs`:

    ```elixir
    def deps do
      [{:tokumei_router, "~> 0.2.0"}]
    end
    ```

  2. Ensure `tokumei_router` is started before your application:

    ```elixir
    def application do
      [applications: [:tokumei_router]]
    end
    ```

## Usage

```elixir
defmodule MyApp.Router do
  import Tokumei.Router
  alias Tokumei.Router.{NotImplementedError, MethodNotAllowedError, NotFoundError}
  alias Raxx.Response

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

The `Tokumei.Router` provides a simple routing DSL that first routes on path and second on request method.
This is done so that `Tokumei.Router` can return the correct responses for resources that will respond to only a subset of HTTP verbs.

```elixir
import Raxx.Request

assert 200 == MyApp.Router.handle_request(get("/hello"), :env)
assert 405 == MyApp.Router.handle_request(put("/hello"), :env)
assert 404 == MyApp.Router.handle_request(put("/random"), :env)
```

Using `Tokumei.Router` will create a Raxx App that can be mounted using any of the adapters found in [Raxx](https://github.com/CrowdHailer/raxx)
