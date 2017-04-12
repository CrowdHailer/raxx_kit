# Tokumei


**Tiny yet MIGHTY Elixir webframework**

### Foundations not framework

Tokumei is the foundation for building web interfaces.
By focusing on **only** the web layer, it is adaptable to any application.

This freedom enables to best application to be build for the domain.
I call this principle XVC (Mind-your-own-business View Controller).

## Documentation

- Get going with the [getting started](guides/getting-started.md) guide.
- Documentation is available on [hex.pm](https://hexdocs.pm/tokumei/readme.html).

## Guides

- [Writing middleware with macros](guides/writing-middleware-with-macros.md), extending applications with custom middleware.
- [Why Raxx](guides/why-raxx.md), the rational behind building a web interface layer for Elixir.

## Examples

- **[WaterCooler](water_cooler)** simple chat room, application.
- **[Fifteen](fifteen)** fifteen minute blog, built around umbrella applications.

## Community

Open an issue to chat, FAQ comming soon.

## Development

Local development requires Elixir 1.3+, OR use vagrant box provided.

## Testing

```
git clone git@github.com:CrowdHailer/Tokumei.git
cd Tokumei/app

mix deps.get
mix test
```

## Contributing

1. Fork it (https://github.com/crowdhailer/tokumei/fork)
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Run all [tests](#testing)
5. Push to the branch (`git push origin my-new-feature`)
6. Create a new Pull Request

## Copyright and License

Tokumei source code is released under [Apache License 2.0](License).
