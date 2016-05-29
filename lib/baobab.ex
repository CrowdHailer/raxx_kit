defmodule RootPage do
  require EEx

  template_file = String.replace_suffix(__ENV__.file, ".ex", ".html.eex")
  EEx.function_from_file :defp, :render_template, template_file, [:assigns]

  def render(assigns) do
    render_template(assigns)
  end

  @escapes [
    {?<, "&lt;"},
    {?>, "&gt;"},
    {?&, "&amp;"},
    {?", "&quot;"},
    {?', "&#39;"}
  ]

  Enum.each @escapes, fn { match, insert } ->
    defp escape_char(unquote(match)), do: unquote(insert)
  end

  defp escape_char(char), do: << char >>

  def escape(buffer) do
    IO.iodata_to_binary(for <<char <- buffer>>, do: escape_char(char))
  end
end
defmodule Baobab do
  defmodule RootController do
    import Plug.Conn

    def init(opts) do
      Map.put(opts, :greeting, "Hello")
    end

    def call(conn, opts) do
      IO.inspect(RootPage.escape("<h1>&</h1>"))
      page = RootPage.render(opts)
      IO.inspect(page)
      send_resp(conn, 200, page)
    end
  end
  use Application

  def start(_type, _args) do
    Plug.Adapters.Cowboy.http(RootController, %{})
  end
end
