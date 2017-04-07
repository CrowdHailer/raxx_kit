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
    - `Tokumei.Session.SignedCookies`
    - `Tokumei.ContentLength`
    - `Tokumei.MethodOverride`
    - `Tokumei.Static`
    - `Tokumei.Head`
    - `Tokumei.CommonLogger`

## Development Goals

- [ ] Document and test templates

- [ ] Make server configurable
- [ ] Extract starting as application from starting as supervised process
- [ ] test starting as endpoint `start_link` and as application `start`

- [ ] HTTP/2 promises API, integration with raxx_chatterbox

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
