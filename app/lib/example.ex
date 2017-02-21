defmodule Example do
  use Tokumei

  config :port, 8080
  config :static, "./public"
  config :templates, "./templates"

  @channel_name :chat

  route([]) do
    get() ->
      ok(home_page(%{}))
    # channel name to be passed as config
    post(%{body: body}) ->
      {:ok, %{message: message}} = parse_publish_form(body)
      {:ok, _} = share_in_chatroom(@channel_name, message)
      redirect("/")
  end

  route(["updates"]) do
    get() ->
      {:ok, _} = join_chatroom(@channel_name)
      SSE.stream(@channel_name)
  end

  # streaming @channel_name do
  #   {:message, message} ->
  #     {:send, message}
  #   _ ->
  #     {:nosend}
  # end
  def handle_info({:message, message}, @channel_name) do
    {:chunk, "event: chat\ndata: #{message}\n\n", :updates}
  end

  def share_in_chatroom(chatroom, message) do
    :gproc.send({:p, :l, :chat}, {:message, message})
    {:ok, message}
  end

  # Should also pass the process to register
  def join_chatroom(room) do
    :gproc.reg({:p, :l, room})
    {:ok, room}
  end

  def parse_publish_form(raw) do
    %{"message" => message} = URI.decode_www_form(raw) |> URI.decode_query
    {:ok, %{message: message}}
  end
end
