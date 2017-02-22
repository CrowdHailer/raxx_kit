# Tokumei

**Tiny but MIGHTY Elixir webframework**

## Getting started (Let's get productive)

*Know all about mix and umbrella projects? [Jump onwards to add tokumei in an exitsting project]()*

```
mix archive.install https://github.com/crowdhailer/tokumei/raw/master/setup.ez
mix tokumei.new my_app
cd my_app
iex -S mix
```

visit [localhost:8080](localhost:8080])

## Installation
This should be obviouse to users interested in setting up their own mix project

If [available in Hex](https://hex.pm/docs/publish), the package can be installed as:

  1. Add `app` to your list of dependencies in `mix.exs`:

    ```elixir
    def deps do
      [{:tokumei, "~> 0.1.0"}]
    end
    ```

  2. Ensure `app` is started before your application:

    ```elixir
    def application do
      [applications: [:app]]
    end
    ```

### Long
```
mix new <app_name>
add step 1 above
add step 2 above
add step 1 above for ace_http
add step 2 above for ace_http
add {mod: {AppName, []} to application
use Tokumei in module
write first route
setup port configuration
```

### Short

```
mix archive.install https://github.com/crowdhailer/tokumei/raw/master/setup.ez
mix tokumei.new my_app
```

In umbrella
```
mix tokumei.new www --mod MyApp.WWW --app myapp_web
```

---sup option uses Tokumei.Server and sets up without the router as an application allows multiple things in one supervision tree.

- [help on archives](https://hashrocket.com/blog/posts/create-and-publish-your-own-elixir-mix-archives)

has instructions in documentation
has port, server, log_level all configured
has first route configured

Setup app should include server sent events.
perhaps each server adds itself to a pg2 group and submitting a form causes it to be recieved in all servers

Why not
```
mix archive.install tokumei
```
