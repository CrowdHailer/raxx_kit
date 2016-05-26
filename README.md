# Baobab

**An example Cowboy application that might grow to be a routing tree example**

## Installation

  1. Add baobab to your list of dependencies in mix.exs:

        def deps do
          [{:baobab, "~> 0.0.1"}]
        end

  2. Ensure baobab is started before your application:

        def application do
          [applications: [:baobab]]
        end

## Notes
Instructions on setting up Cowboy are reasonably limited.
Some of these resources are helpful.

- [Cowboy elixir example](https://github.com/IdahoEv/cowboy-elixir-example/blob/master/lib/dynamic_page_handler.ex)
- [Elixir rest with cowboy](http://www.jonasrichard.com/2016/02/elixir-rest-with-cowboy.html)

The plug documentation is also lacking.
It seams only to exist to serve Phoenix, however these articles are helpful.

- [Building a web framework from scratch in Elixir](https://codewords.recurse.com/issues/five/building-a-web-framework-from-scratch-in-elixir)
- [Getting started with Plug in Elixir](http://www.brianstorti.com/getting-started-with-plug-elixir/)
