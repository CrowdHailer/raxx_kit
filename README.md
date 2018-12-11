# Raxx.Kit

Raxx.Kit is a project generator for creating boilerplate code for an Elixir web project and
getting started with [Raxx](https://github.com/crowdhailer/raxx)/[Ace](https://github.com/CrowdHailer/Ace).

**Get started with Raxx + Elixir**

```sh
$ mix archive.install hex raxx_kit
$ mix raxx.kit my_app
```

Includes:

- Isolated web layer with [Raxx](https://github.com/crowdhailer/raxx)
- HTTP/2 support with [Ace](https://github.com/CrowdHailer/Ace) server
- Middleware for request logging and static content.
- [Ecto 3.0](https://github.com/elixir-ecto/ecto_sql) and PostgreSQL integration
- Controller unit tests
- Code reloading with [ExSync](https://github.com/falood/exsync)

[Tutorial for building a distributed chatroom with Raxx.Kit](http://crowdhailer.me/2018-05-01/building-a-distributed-chatroom-with-raxx-kit/)

### Options

- `--ecto`: Adds Ecto as a dependency and configures project to use
  a Postgres database. If used with `--docker` flag, a docker-compose service
  with the database will get generated.

- `--node-assets`: Add JavaScript compilation as part of a generated project.
  Works with or without docker.

- `--docker`: Create `Dockerfile` and `docker-compose.yml` in template.
  This allows local development to be conducted completly in docker.

- `--module`: Used to name the top level module used in the generated project.
  Without this option the module name will be generated from path option.

  ```sh
  $ mix raxx.kit my_app

  # Is equivalent to
  $ mix raxx.kit my_app --module MyApp
  ```

- `--no-exsync`: Doesn't include exsync in the generated project. Changed
  files won't be rebuilt on the fly when the app is running.

### Next

- [Check Raxx documentation on hexdocs](https://hexdocs.pm/raxx)
- [Join Raxx discussion on slack](https://elixir-lang.slack.com/messages/C56H3TBH8/)

## Contributing

**NOTE: dotfiles in the priv directory are not automatically included in an archive.**

## Copyright and License

Raxx.Kit source code is released under [Apache License 2.0](License).
