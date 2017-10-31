# Tokumei

**Toolkit for building cloud native web applications with Docker.**

[![Hex pm](http://img.shields.io/hexpm/v/tokumei.svg?style=flat)](https://hex.pm/packages/tokumei)
[![Build Status](https://secure.travis-ci.org/CrowdHailer/tokumei.svg?branch=master
"Build Status")](https://travis-ci.org/CrowdHailer/tokumei)
[![License](https://img.shields.io/badge/License-Apache%202.0-blue.svg)](LICENSE)

*Tokumei can be used without making use of the generators described below. Simply require from hex as if it were any other library*

- [Install from hex.pm](https://hex.pm/packages/tokumei)
- [Documentation available on hexdoc](https://hexdocs.pm/tokumei)

### Foundations not framework

Tokumei is the foundation for building web interfaces.
By focusing on **only** the web layer, it is adaptable to any application.

This freedom enables to best application to be build for the domain.
I call this principle XVC (Mind-your-own-business View Controller).


## Community

- [elixir-lang slack channel](https://elixir-lang.slack.com/messages/C56H3TBH8/)
- *FAQ comming soon.*

## Development

Local development requires Elixir 1.4+

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
