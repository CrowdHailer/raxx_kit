# Raxx.Kit

**Get started with Raxx + Elixir**

Includes:

- Isolated web layer with [Raxx](https://github.com/crowdhailer/raxx)
- HTTP/2 support with [Ace](https://github.com/CrowdHailer/Ace) server
- API documentation with API Blueprint, use `--apib`.
- Middleware for request logging and static content.
- Controller unit tests
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

By default, the new project will accept http connections on port `8080` and https connections on port `8443`.
Visiting http://localhost:8080 should show the homepage.
Visiting https://localhost:8443 will use HTTP/2 but you will need to accept the self signed certificate or generate a new one.

### Next

- [Check Raxx documentation on hexdocs](https://hexdocs.pm/raxx)
- [Join Raxx discussion on slack](https://elixir-lang.slack.com/messages/C56H3TBH8/)

### Options

- The `--docker` option will add the files `Dockerfile` and `docker-compose.yml`.
  This allows local development to be conducted completly in docker.

- The `--module` option can be used to name the top level module used in the generated project. Without this option the module name will be generated from path option.

  ```sh
  $ mix raxx.kit my_app

  # Is equivalent to
  $ mix raxx.kit my_app --module MyApp
  ```

- The `--apib` option will generate an API Blueprint file which is used as the project router.

## Copyright and License

Raxx.Kit source code is released under [Apache License 2.0](License).
