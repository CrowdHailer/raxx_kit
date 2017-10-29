# Tokumei

**Toolkit for building cloud native web applications with Docker.**

[![Hex pm](http://img.shields.io/hexpm/v/tokumei.svg?style=flat)](https://hex.pm/packages/tokumei)
[![Build Status](https://secure.travis-ci.org/CrowdHailer/tokumei.svg?branch=master
"Build Status")](https://travis-ci.org/CrowdHailer/tokumei)
[![License](https://img.shields.io/badge/License-Apache%202.0-blue.svg)](LICENSE)

*Tokumei can be used without making use of the generators described below. Simply require from hex as if it were any other library*

- [Install from hex.pm](https://hex.pm/packages/tokumei)
- [Documentation available on hexdoc](https://hexdocs.pm/tokumei)

## Getting started

To use the Tokumei generator Docker must be installed.
Docker is assumed as dependency for modern cloud native application development.
Tokumei uses it to setup multiple instances of services allowing systems to be scalable and resiliant

```
docker run -v $PWD:/tmp tokumei/embark my_app
cd my_app
docker-compose up
```

Visit [https://localhost:8443](https://localhost:8443) from your browser.

See your new projects `README.md` for working with your new service.


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

- **[WaterCooler](water_cooler)** simple chat application.
- **[Fifteen](fifteen)** fifteen minute blog, built around umbrella applications.

## Community

- [elixir-lang slack channel](https://elixir-lang.slack.com/messages/C56H3TBH8/)
- *FAQ comming soon.*

## Development

Local development requires Elixir 1.4+, OR use vagrant box provided.

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
