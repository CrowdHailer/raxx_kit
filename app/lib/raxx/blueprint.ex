defmodule Raxx.Blueprint do
  @moduledoc """
  Route requests based on API Blueprint

  """

  # elements should be api elements in the future
  defmacro __using__(path = {_, _, _}) do
    quote do
      blueprint = File.read!(unquote(path))

      Module.eval_quoted(__ENV__, quote do: use Raxx.Blueprint, unquote(blueprint))
    end
  end
  defmacro __using__(rel = "./" <> _) do
    quote do
      use Raxx.Blueprint, Path.join(__DIR__, unquote(rel))
    end
  end
  defmacro __using__(blueprint) when is_binary(blueprint) do
    {namespace, []} = Module.eval_quoted(__CALLER__, (quote do: __MODULE__))

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
