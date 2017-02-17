# Tokumei

**A tiny but mighty Elixir webframework**

## Installation

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

- [help on archives](https://hashrocket.com/blog/posts/create-and-publish-your-own-elixir-mix-archives)

has instructions in documentation
has port, server, log_level all configured
has first route configured

Why not
```
mix archive.install tokumei
```
