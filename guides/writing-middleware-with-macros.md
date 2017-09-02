# Writing middleware with Macros

### RAXX 0.12.0 MAKES CHANGES TO INTERFACE DESCRIBED HERE.

- *[CrowdHailer](http://crowdhailer.me/) - 08 April 2017*

---

Middleware is software that modifies the behaviour of other software.
They are the perfect place to implement functionality that applies to many routes.

Examples of such cross cutting functionality include authorization, parsing content and monitoring.
In this walkthrough we will create middleware that adds logging to an application.

## Hello, World!

Let's get started with an application that needs logging.
We will use a simple hello world example.
It has one route for the home page.
All other requests return with 404.

```elixir
defmodule GreetingApp do
  alias Raxx.Response

  def handle_request(%{path: []}, _config) do
    Response.ok("Hello, World!")
  end

  def handle_request(_request, _config) do
    Response.not_found("Nothing here.")
  end
end
```

## Defining Middleware

Our greeting app now just requires logging.
The naive solution is to add call to `Logger` in every action handler.

There are a few reasons why this solution is poor.
First we will be duplicating code in every action handler, which in turn means that it is easy to make a mistake so that one routes ends up without the logging required.
Second the added code is bundled into that action handler and obscures the main purpose of that route.

A desirable solution is one that adds logging to every route without modifying the action handler's code.
We can build this solution using `defoverridable/1`.
This allows us to redefine a function. From this redefined function we can call back to the previous implementation using `super`.

In combination this allows us to add logging to our app without modifying or obscuring existing action handlers.

```elixir
defmodule GreetingApp do

  # ... original action handlers the same

  defoverridable [handle_request: 2]

  require Logger

  def handle_request(request, config) do

    # Call the previous version of `handle_request/2` using `super`
    response = super(request, config)
    log_request_and_response(request, response)
    response
  end

  defp log_request_and_response(%{path: path, method: method}, %{status: status}) do
    path = Enum.join(path, "/")
    Logger.info("#{method} #{path} -> #{status}")
  end
end
```

We can now start `GreetingApp` app.
After a few requests have been made to the server we can see the logs include extra details for requests.

```
[info] GreetingApp is listening on port: 8080
[info] GET / -> 200
[info] GET /random -> 404
```

## Reusing Middleware

Great. This logger does exactly what we need.

Let's extract our logging functionality so it can be reused across all our projects.
To implement this version we need to turn to Elixir macros.
A Macro is just code that writes code.
We want to write a `MyLogger` module that adds logging to any module it is used in.

This next example does just that.

```elixir
defmodule MyLogger do

  # Define a macro that will be called when this module is used.
  defmacro __using__(_opts) do
    quote do

      # The module will require the logger later
      require Logger

      # We can't override functions that do not exist.
      # Adding this line allows to module override the function after the user has defined all the routes.
      @before_compile unquote(__MODULE__)
    end
  end

  # Define a macro that will be called after all module definitions
  defmacro __before_compile__(_env) do
    quote do

      # Define all the code that we want to add to our module
      defoverridable [handle_request: 2]

      def handle_request(request, config) do

        # Call the previous version of `handle_request/2` using `super`
        response = super(request, config)
        log_request_and_response(request, response)
        response
      end

      defp log_request_and_response(%{path: path, method: method}, %{status: status}) do
        path = Enum.join(path, "/")
        Logger.info("#{method} #{path} -> #{status}")
      end
    end
  end
end
```

## Combining middleware

Any Raxx application can now have logging by using `MyLogger`.
It is possible to override a function multiple times.
In this way multiple middleware can be defined and stacked to combine their behaviour.

All functionality in Tokumei is contained in middleware, including routing.

To finish this example let's simplify our code.
We can stack `MyLogger` with routing middleware included as part of Tokumei.

```elixir
defmodule GreetingApp do
  alias Raxx.Response

  # middleware stack
  use Tokumei.NotFound
  use Tokumei.Routing
  use MyLogger

  route [] do
    Response.ok("Hello, World!")
  end
end
```

## Conclusion

Middleware allows us to separate different concerns of our application into easily reusable chunks.
It is simple to implement using the constructs provided by Elixir.
