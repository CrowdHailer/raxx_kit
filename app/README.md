# Tokumei

**Tiny but MIGHTY Elixir webframework**

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
