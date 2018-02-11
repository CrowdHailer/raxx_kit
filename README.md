# Raxx.Kit

**Get started with Raxx + Elixir**

Includes:

- Isolated web layer with [Raxx](https://github.com/crowdhailer/raxx)
- HTTP/2 support with [Ace](https://github.com/CrowdHailer/Ace) server
- Middleware for request logging and static content.
- Code reloading with [ExSync](https://github.com/falood/exsync)

### Installation

```sh
$ mix archive.install https://github.com/CrowdHailer/raxx_kit/raw/master/raxx_kit.ez
```

### Create a project

```sh
$ mix raxx.kit my_app
```

See [options](#options) to customise.

### Start project

```sh
$ cd my_app
$ iex -S mix
```

By default, the new project will accept connections on port `8080`.
Visiting https://localhost:8080 should show the homepage.

### Next

- [Check Raxx documentation on hexdocs](https://hexdocs.pm/raxx)
- [Join Raxx discussion on slack](https://elixir-lang.slack.com/messages/C56H3TBH8/)

### Options

- The `--module` option can be used to name the top level module used in the generated project. Without this option the module name will be generated from path option.

```sh
$ mix raxx.kit my_app

# Is equivalent to
$ mix raxx.kit my_app --module MyApp
```

## Copyright and License

Raxx.Kit source code is released under [Apache License 2.0](License).
