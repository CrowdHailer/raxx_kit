# Getting started

```
docker run -v $(pwd):/tmp tokumei/embark hello_tokumei
cd hello_tokumei
docker-compose up
```

Visit [localhost:8080](http://localhost:8080) from your browser.

See your new projects `README.md` for working with your new service.

*Don't have docker installed? see Manual setup below.*

## Manual setup

## Valid for version `0.7.1` and earlier only.

Go to [Raxx channel](https://elixir-lang.slack.com/messages/C56H3TBH8/) for latest.

### Create a new mix project

First use mix to setup a new elixir project.

```
mix new greetings_app --sup
cd greetings_app
```

Using `--sup` includes a supervision tree.
This will oversee a webserver for the application.

**Umbrella applications**,
A Tokumei application can be part of an umbrella or run independently.
For larger project umbrella applications are recommended.

### Add Tokumei and webserver

Add `:tokumei` to the list of dependencies.
We will use `:ace_http` for a webserver.

```elixir
# mix.exs

  defp deps do
    [
      {:tokumei, "~> 0.6.4"},
      {:ace_http, "~> 0.4.5"}
    ]
  end
```

Run the mix task to fetch our dependencies.

```
mix dep.get
```

**Supported webservers**,
several other webservers are available,
see [Raxx](https://github.com/CrowdHailer/raxx) for details.

## Setup

### Define the application

All we need to make a compatible Raxx application is to use `Tokumei`.
This module will become the entry point for web requests to our application.

```elixir
defmodule GreetingsApp.WWW do
  use Tokumei
end
```

### Starting the webserver

Once the application is defined it needs to be mounted on a server.
Next we need a server to host it.

```elixir
# lib/greetings_app.ex

defmodule GreetingsApp do
  use Application

  def start(_type, _args) do
    GreetingsApp.WWW.start_link([port: 8080, name: GreetingsApp.WWW])
  end
end
```

To start the whole application, server included, use `iex`.

```
iex -S mix
```

Visit [localhost:8080](localhost:8080)

### Write tests

Testing applications built with Tokumei is incredibly easy.
This is because under the hood it uses the simple Raxx interface.

```elixir
test "The homepage should return a status 200 response" do
  response = Raxx.Request.get("/") |> GreetingsApp.WWW.handle_request(%{})
  assert response.status == 200
  assert response.body == "Hello, World!"
end

test "The www app has an action for the home page" do
  assert "/" == GreetingsApp.WWW.path(:index)
end
```

Run our tests using mix and we should see two failing tests

```
mix test
```

## Development

With the application, server and tests setup we can start adding features.

### Routing

Routing is pattern matching a requests path to action handlers.
Paths in Tokumei (and Raxx) are represented as a list of segments.

To serve an index page create a route for `[]`.

```elixir
# lib/greetings_app/www.ex

defmodule GreetingsApp.WWW do
  use Tokumei

  @route_name :index
  route [] do
    :GET ->
      Response.ok("Hello, World!")
  end
end
```

See `Tokumei.Router` for further information on routing.

### Templates

Create a template for the homepage at `lib/greetings_app/www/templates/home_page.html.eex`.

```html
<!-- lib/greetings_app/www/templates/home_page.html.eex -->
<h1><%= @message %></h1>   
```

Using `Tokumei` will compile all `.eex` templates from a `./templates` directory (relative to the router file).
Render functions are available for each template and are called with a map of values.

```elixir
# :index action
:GET ->
  Response.ok(render("home_page.html", %{message: "Hello, World!"}))
```

**Content Type**,
`Tokumei.Templates` will add a content type to the response generated from the render function.
The content type is derived from the file extension.
A file called `home_page.html.eex` will generate a render function setting content type to `text/html`.

### Static content

To add a favicon save one to `lib/greetings_app/www/public/favicon.ico`.

Content in `./public` directory (relative to the router file) is automatically served.

See `Tokumei.Static` for more details.

### Error handling
Tokumei action handlers are expected to return a response or a error tuple.
Error handlers are used to transform errors to a valid response.

```elixir
# lib/greetings_app/www.ex

defmodule GreetingsApp.WWW do
  use Tokumei

  @route_name :index
  route [] do
    :GET ->
      Response.ok("Hello, World!")
    :POST ->
      {:error, :bad_request}
  end

  error :bad_request do
    Response.bad_request("This request was no good.")
  end

  error %NotFoundError{path: path} do
    Response.not_found("Nothing here :-(")
  end
end
```

*A not `NotFoundError` exception is returned for any request that doesn't match to an action handler.*

See `Tokumei.ErrorHandler` for more options to handle errors.

### Helpers

`Tokumei` adds helpers to implement action handlers.

Lets rewrite our error handler so that users are redirected to the home page.

```elixir
  # :error handler
  error %NotFoundError{path: path} do
    redirect(path(:index))
    |> Flash.write(error: "Redirected from missing path")
  end
```

See `Tokumei.Helpers` for the full range of available helpers.

### Requests

HTTP requests are passed to action handlers as a `Raxx.Request`.
These objects contain metadata associated with the request.

```elixir
@route_name :info
route ["info"], request do
  :GET ->
    IO.inspect(request.scheme)  # "http"
    IO.inspect(request.host)    # "www.example.com"
    IO.inspect(request.port)    # 8080
    IO.inspect(request.method)  # :GET
    IO.inspect(request.mount)   # []
    IO.inspect(request.path)    # ["info"]
    IO.inspect(request.query)   # %{"page" => "5"}
    IO.inspect(request.headers) # [{"accept", "text/html"}]
    IO.inspect(request.body)    # "Lorem ..."
end
```

### Configuration

Configuration is available to action handlers as the third argument to a route.

```elixir
route ["config"], _request, config do
  :GET ->
    IO.inspect(config)
end
```

## Deployment

### Heroku
1. create app
```
heroku apps:create eexperiment
```

1. Load up build pack
```
heroku buildpacks:set https://github.com/HashNuke/heroku-buildpack-elixir.git
```

2. make sure port is taken from env variable

  ```elixir
  {port, ""} = System.get_env("PORT") |> Integer.parse()

  children = [
    worker(Ace.HTTP, [server, [port: port, name: Tmp.WWW]])
  ]
  ```

2. push
```
git add .
git commit -m 'initial commit'
git push heroku master
```

### Building releases

Using releases is probably the recommended way to deploy elixir applications.
Release can be build in Vagrant.
This section of the getting started guide will use Vagrant, see `/vm_sandox` for setup.

## More

### Code reloading

*NOTE: On Linux you may need to install `inotify-tools`.*

[ExSync](https://github.com/falood/exsync) is a general purpose code reloading facility.
First add it to the list of dependencies.

```elixir
# mix.exs

  defp deps do
    [
      # ... previous dependencies
      {:exsync, "~> 0.1", only: :dev}
    ]
  end
```

Then modify the applications to run ExSync on startup.

```elixir
# lib/greetings_app.ex

defmodule GreetingsApp.WWW do
  use Application

  def start(_type, _args) do
    import Supervisor.Spec, warn: false

    case Code.ensure_loaded(ExSync) do
      {:module, ExSync} ->
        ExSync.start()
      {:error, :nofile} ->
        :ok
    end

    # ... rest of applications start script.
  end
end
```

**Development dependencies**,
are loaded only when working in the development environment.
By using `ensure_loaded/1` we will only start code reloaded in the appropriate enviroments.

## Where next

- flash, see `Tokumei.Flash`
- sessions, see `Tokumei.Session.SignedCookies`
- HTTPS, see guide [security with HTTPS](https://hexdocs.pm/tokumei/security-with-https.html)
- middleware, see guide [writing middleware with macros](https://hexdocs.pm/tokumei/writing-middleware-with-macros.html)
- streaming (In progress, awaiting updated Raxx)
- large projects router/action_handler/umbrellas
  overkill action handler and domain (In progress)
