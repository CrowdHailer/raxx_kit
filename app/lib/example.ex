defmodule Example do
  use Tokumei
  import Tokumei.Helpers

  config :port, 8080

  route([]) do
    get() -> Raxx.Response.ok(html("""
    <form action="/" method="post">
      <input type="text" name="message">
      <button type="submit">Send</button>
    </form>
    """))
    post(%{body: body}) ->
      data = URI.decode_www_form(body) |> URI.decode_query
      case data do
        %{"message" => message} ->
          IO.inspect("sending")
          :gproc.send({:p, :l, :chat}, {:message, message})
          |> IO.inspect
      end
      Raxx.Response.found([{"location", "/"}])
  end

  route(["updates"]) do
    get() ->
      :gproc.reg({:p, :l, :chat})
      |> IO.inspect
      receive do
        {:message, message} ->
          Raxx.Response.ok(html(message))
      end
  end

  route(["favicon.ico"]) do
    get() -> Raxx.Response.not_found()
  end

  def html(body) do
    %{body: body, headers: [{"content-type", "text/html"}]}
  end

end
