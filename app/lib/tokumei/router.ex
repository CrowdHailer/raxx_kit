defmodule Tokumei.Router do
  @moduledoc """
  Simplest Router for Raxx Applications

  Provides `route/2/3/4` to direct requests to handlers

      defmodule MyApp.Router
        use Tokumei.Router

        # Any value can be returned by a route.
        # import helpers from Raxx.Response to return valid response to the Raxx.Server
        import Raxx.Response

        # route_name is optional

        # Routes are created in blocks grouped, first by path...
        @route_name :users
        route ["users"], request, _config do

          # ...and second by request method.
          :GET ->
            ok("Dan, Lucy, Jane")
          :POST ->
            created("Added \#{request.body}")
        end

        # If access to the request and config is not needed use `route/2`
        route ["about"] do
          :GET ->
            ok("All about Tokumei.Router")
        end

        # paths may contain any number of variables
        @route_name :users_cart
        route ["users", user_id, "carts", cart_id], request do
          :GET ->
            ok("This is cart: '\#{cart_id}' for user: '\#{user_id}'")
        end

        # Application configuration is optional third argument.
        @route_name :forgot_password
        route ["users", "forgot-password"], _request, %{mailer: mailer} do
          :POST ->
            mailer.send_password_reset(request.body)
            ok("Reset sent")
        end

        # Tokumei.Router is implemented as middleware.
        # A fallback `handle_request/2` must implemented.
        # This can be handled by earlier middleware, e.g. Tokumei.NotFound
        def handle_request(request, _) do

          # Checkout Raxx.ErrorHandler for consolidating managing error return values.
          {:error, {:not_found, request}}
        end
      end

  The router will be a Raxx application, it can be invoked directly.
  For example for testing

      request = Raxx.Request.get("/users")
      response = MyApp.Router.handle_request(request, :some_config)
      assert %{body: "Dan, Lucy, Jane", status: 200} = response

      request = Raxx.Request.post("/users", "Bill")
      response = MyApp.Router.handle_request(request, :some_config)
      assert %{body: "Added Bill", status: 201} = response

  It can be mounted on a Raxx compatible server

      {:ok, pid} = Ace.HTTP.start_link({MyApp.Router, :some_config}, port: 8080)

  **NOTE: Tokumei.Router does not provide any guarantees on return value.
  It can be used in conjunction with other middleware to ensure responses can be sent to client,
  e.g. Raxx.ErrorHandler, Raxx.ContentLength etc.**

  The router will have helpers for generating paths from route names.

      assert "/users" == MyApp.Router.path_to(:users)

      assert "/users/jill" == MyApp.Router.path_to(:user, ["jill"])

  The router will have helpers for generating fully qualified urls from route names.

      request = %Raxx.Request{host: "www.example.com", scheme: "http", mount: ["api"]}

      assert "http://www.example.com/api/users" == url_to(request, :users)

      assert "http://www.example.com/api/users/jill" == url_to(request, :user, ["jill"])

  ## Extensions

  `Tokumei.Router` helps create Raxx Handlers, with the aim of improving readability.
  The DSL is deliberatly minimal, to maintain the underlying semantics.
  However the following extensions might be useful,
  and can be added if enough usecases are found.

  - [ ] Don't create raxx_path for :unnamed routes
  - [ ] Automatically add the 405 Method Not Implemented clause by inspecting matches
  - [ ] Being able to fetch a list of all the routes implemented.
    - simplest is to return all route names, MyRouter.routes() -> [:users, :user, :root]
    - useful to return representation of paths, but have to be built from match
      - :user "[\"users\", id]" # built using Macro.to_string
      - :user "/users/:id" # requires deconstruction of match
    - useful to list all implemented methods, tricky as methods can be match in serveral non-trivial ways
      - :GET -> # action
      - m when in [:POST, :PATCH] -> # action
      - because list of known methods is small we could execute the action clause finding out the known methods
  - [ ] Being able to list all the routes from a mix task
        ```
        "/",          [GET]
        :users "/users",     [GET, POST]
        :user  "/users/:id", [GET, PATCH, DELETE]
        ```
  - [ ] mount functionality
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
  - [ ] Direct routing to controllers
        ```elixir
        @route_name :home
        route "/",
          GET: HomePage,
          POST: SendEnquiry

        @route_name :home
        route "/", {request, config} do
          :GET -> HomePage.handle_request(request, config),
          :POST -> SendEnquiry.handle_request(request, config)
        end
        ```
    - Simplifies knowing about methods implemented if setup as kwlist not match
    - Perhaps belongs as separate dispatcher (or similar named module)
  - [ ] handle situation where a super value is not defined
    - `Module.defines?(__MODULE__, {:handle_request, 2})`
  - [ ] Gateway functionality for direct forwarding to {ip, port}, hashtag microservices
  - [ ] Handle globbing eg `["stuff" | rest]`.
    Though maybe this can be solved with mount. I have never used variables and globs in the same route.
  """
  defmacro __using__(_) do
    quote do
      import unquote(__MODULE__), only: [route: 2, route: 3, route: 4]
      @before_compile unquote(__MODULE__)

      @route_name :unnamed
    end
  end

  defmacro __before_compile__(_env) do
    quote do

      def handle_route(_, _, %{path: path}, _env) do
        {:error, {unquote(__MODULE__), :not_found}}
      end

      defoverridable [handle_request: 2]
      def handle_request(request = %{path: path, method: method}, config) do
        handle_route(path, method, request, config)
        |> case do
          {:error, {unquote(__MODULE__), :not_found}} ->
            super(request, config)
          handled ->
            handled
        end
      end

      def path_to(name, vars \\ []) do
        raxx_path(name, List.wrap(vars))
        |> Enum.join("/")
        # Possibly should not add this path is relative if mounting is a possibility
        |> (&("/" <> &1)).()
      end

      def url_to(request, name, vars \\ []) do
        path = raxx_path(name, List.wrap(vars))
        request = %{request | path: path}
        Tokumei.Patch.request_to_url(request)
      end
    end
  end

  @doc """
  Implements route with request and config unmatched.
  See `route/4`.
  """
  defmacro route(match, do: actions) do
    quote do
      route unquote(match), _, _, do: unquote(actions)
    end
  end

  @doc """
  Implements route with config unmatched.
  See `route/4`.
  """
  defmacro route(match, request, do: actions) do
    quote do
      route unquote(match), unquote(request), _, do: unquote(actions)
    end
  end

  @doc """
  Define action to take for each route.

  Requires an expression representing the route path.
  All incoming requests are tested against the routes in the order they are defined.
  If a request matches then the route action is invoked.
  """
  defmacro route(match, request, config, do: actions) do
    args = Enum.reject(match, &(is_binary(&1)))
    quote do
      defp raxx_path(@route_name, unquote(args)) do
        unquote(match)
      end
      def handle_route(unquote(match), method, unquote(request), unquote(config)) do
        case method do
          unquote(actions)
        end
      end
    end
  end
end
