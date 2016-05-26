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
