# Tokumei

**Tiny but MIGHTY Elixir webframework**

```elixir
defmodule MyApp.WWW do
  Use Tokumei

  @static "./public"

  route ["greeting", name] do
    :GET ->
      ok("Hello, #{name}!")
  end

  error %NotFoundError do
    not_found("Could not find what you were looking for!")
  end
end
```

## Dive in

<!-- *Know all about mix and umbrella projects? [Jump onwards to add tokumei in an exitsting project]()* -->

*N.B. Generator outdated setups up 0.3.0 project*
```
mix archive.install https://github.com/crowdhailer/tokumei/raw/master/tokumei_new.ez
mix tokumei.new my_app
cd my_app
iex -S mix
```

visit [localhost:8080](localhost:8080])

## Usage

1. Explore the water cooler example in this [repository](https://github.com/CrowdHailer/Tokumei/tree/master/water_cooler).
2. Documentation is available, [on hexdocs](https://hexdocs.pm/tokumei/), for all middleware modules.
    - `Tokumei.Router`
    - `Tokumei.ErrorHandler`
    - `Tokumei.Flash.Query`
    - `Tokumei.ContentLength`
    - `Tokumei.MethodOverride`
    - `Tokumei.Static`
    - `Tokumei.Head`
    - `Tokumei.CommonLogger`

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

- [x] named routes
- [x] path/url helpers
- [x] Draft designing a DSL

- [x] mod docs routing
- [x] all middleware mod docs
- [ ] write overview article

- [ ] Document and test templates

- [ ] Make server configurable
- [ ] Extract starting as application from starting as supervised process
- [ ] test starting as endpoint `start_link` and as application `start`

- [x] publish why raxx article
- [ ] publish build your own middleware article

- [ ] chunked responses
- [ ] Test streaming
- [ ] Handle messages to server without sending a chunk
- [ ] Handle fact that server pid may be known after streaming completes, subscriptions are still open, possibly always close
- [ ] mod docs streaming

- [ ] HTTPS setup with lets encrypt
- [ ] article Setting up without generator

- [ ] Deployment examples. Digital Ocean, Vagrant, Kuberneties
- [ ] Add wobserver

- [ ] Handle Server Errors, url too long, request too slow, request too large

- [ ] remove redirect from patch
- [ ] back(request) -> response

- [ ] Cookies, Sessions
- [x] Flash

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
