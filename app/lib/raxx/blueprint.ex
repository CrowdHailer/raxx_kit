defmodule Raxx.Blueprint do
  @moduledoc """
  Use an API Blueprint file as a router for Raxx server definitions.

  *Because are you really going to write the documentation afterwards.*

      defmodule MyApp do
        use Raxx.Server
        use Raxx.Blueprint, "./my_app.apib"
      end

  **Module lookup**

  In a blueprint file actions can be given names.
  To work with `Raxx.Blueprint` actions need to be named.
  A module name is generated from these names and added as the handler for that route.
  For example given the blueprint below the router will assume there exits a module `MyApp.CreateAMessage`
  It will use this as the controller for all request to `POST /messages`.

      FORMAT: 1A

      # Messages [/messages]
      ## Create a message [POST]
  """

  defmacro __using__(path) when is_binary(path) do
    # Expand whatever the user has done to their path
    {path, []} = Module.eval_quoted(__CALLER__, path)
    # If a relative path is given expand in relation to the callers file
    path = Path.expand(path, Path.dirname(__CALLER__.file))
    {namespace, []} = Module.eval_quoted(__CALLER__, (quote do: __MODULE__))

    blueprint = File.read!(path)

    routing_tree = parse(blueprint)
    actions = routing_tree_to_actions(routing_tree)

    routes = for {method, path, module} <- actions do
      path = path_template_to_match(path)
      {quote do
        %{method: unquote(method), path: unquote(path)}
      end, Module.concat(namespace, module)}
    end

    quote do
      use Raxx.Server
      use Raxx.Router, unquote(routes)
    end
  end

  # TODO calc path match before flat map
  defp routing_tree_to_actions(parsed) do
    Enum.flat_map(parsed, fn({path, actions}) ->
      Enum.map(actions, fn({method, module}) ->
        {method, path, module}
      end)
    end)
  end

  defp path_template_to_match(path_template) do
    path_template
    |> Raxx.split_path()
    |> Enum.map(&template_segment_to_match/1)
  end

  defp template_segment_to_match(segment) do
    case String.split(segment, ~r/[{}]/) do
      [raw] ->
        raw
      ["", _name, ""] ->
        Macro.var(:_, nil)
    end
  end

  def parse(source) do
    source
    |> String.to_charlist()
    |> :blueprint_lexer.string
    |> case do
      {:ok, tokens, _last_line} ->
        collate(tokens)
    end
  end

  defp collate([{:start, _line} | tokens]) do
    Enum.reduce(tokens, [], &push_token/2)
  end

  defp push_token({:resource, _line, charlist}, ast) do
    string = "#{charlist}"
    Regex.named_captures(~r/^#\s(?<name>[a-zA-Z\s]+)\[(?<template>[\/[a-z\/{}]+)\]$/, string)
    |> case do
      %{"name" => _raw_name, "template" => path_template} ->
        [{path_template, []} | ast]
    end
  end
  defp push_token({:action, _line, charlist}, [{path_template, actions} | rest]) do
    string = "#{charlist}"
    Regex.named_captures(~r/^##\s(?<name>[a-zA-Z\s]+)\[(?<method>[\/[A-Z]+)\]/, string)
    |> case do
      %{"name" => name, "method" => method} ->
        method = String.to_existing_atom(method)
        module = to_module_name(name)
        [{path_template, actions ++ [{method, module}]} | rest]
    end
  end

  defp to_module_name(name) do
    name
    |> String.split(~r/\s+/)
    |> Enum.filter(fn(part) -> part != "" end)
    |> Enum.map(&String.capitalize/1)
    |> Enum.join("")
    |> String.to_atom()
  end
end
