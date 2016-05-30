defmodule RootPage do
  defmodule Header do
    use HtmlView, %{template_file: "lib/header.html.eex"}
  end
  defmodule UserPartial do
    use HtmlView, %{template_file: "lib/user_partial.html.eex"}
  end

  use HtmlView

  def header do
    Header.html
  end

  def user_partial(user) do
    UserPartial.html(user)
  end
end
defmodule NotFoundPage do
  use HtmlView, %{template_file: "lib/not_found.html.eex"}
end

defmodule Baobab do
  defmodule RootController do
    import Plug.Conn

    def init(opts) do
      opts
      |> Map.put(:greeting, "Hello")
      |> Map.put(:other, "<h1>&</h1>")
      |> Map.put(:users, [%{name: "jimmey"}, %{name: "Briany"}])
    end

    def call(conn = %{path_info: []}, opts) do
      send_resp(conn, 200, RootPage.html(opts))
    end

    use Plug.Builder
    plug Plug.Static,
      at: "/",
      from: __DIR__
    plug :not_found

    def not_found(conn, _) do
      send_resp(conn, 404, NotFound.html)
    end
  end
  use Application

  def start(_type, _args) do
    Plug.Adapters.Cowboy.http(RootController, %{})
  end
end
