# Raxx.Kit

**Get started with Raxx + Elixir**

```sh
$ mix archive.install hex raxx_kit
$ mix raxx.kit my_app
```

Includes:

- Isolated web layer with [Raxx](https://github.com/crowdhailer/raxx)
- HTTP/2 support with [Ace](https://github.com/CrowdHailer/Ace) server
- Middleware for request logging and static content.
- Controller unit tests
- Code reloading with [ExSync](https://github.com/falood/exsync)

### Options

- `--node-assets`: Add JavaScript compilation as part of a generated project.
  Works with or without docker.

- `--docker`: Create `Dockerfile` and `docker-compose.yml` in template.
  This allows local development to be conducted completly in docker.

- `--module`: Used to name the top level module used in the generated project. Without this option the module name will be generated from path option.

  ```sh
  $ mix raxx.kit my_app

  # Is equivalent to
  $ mix raxx.kit my_app --module MyApp
  ```

- `--apib`: Generate an API Blueprint file which is used as the project router.

### Next

- [Check Raxx documentation on hexdocs](https://hexdocs.pm/raxx)
- [Join Raxx discussion on slack](https://elixir-lang.slack.com/messages/C56H3TBH8/)

## Contributing

**NOTE: dotfiles in the priv directory are not automatically included in an archive.**

## Copyright and License

Raxx.Kit source code is released under [Apache License 2.0](License).
