# Interface design for HTTP streaming

- *[CrowdHailer](http://crowdhailer.me/) - 25 September 2017*

---

Raxx is a server interface originally based on Ruby's [Rack interface](https://rack.github.io/).
To support streaming, Raxx has fundamentally changed from version 0.12.0.
These changes were necessary to support HTTP/2 in [Ace](https://hex.pm/packages/ace).

*If starting with Raxx after `0.12.0`,
you can find the latest documentation [here](https://hexdocs.pm/raxx/).*

### HTTP overview

The purpose of an HTTP server is to transform a client request into a response.
The simplest representation would be a single function accepting a request and returning a response.

Prior to `0.12.0` the Raxx interface was built on this simple concept.

I have previously [talked](https://www.youtube.com/watch?v=80AXtvXFIA4)
and [written](https://hexdocs.pm/tokumei/why-raxx.html)
about this implementation.

This simple implementation has been deployed successfully.
However the absence of a streaming solution is limiting for several usecases.

- Inefficient to hold complete messages in memory when the body is large.
- Impossible to send a response after just reading the head of a request.
- Unable to implement server streaming when data is sent indefinitely as it becomes available.
- Limiting when working with HTTP/2 features such as push promises.

### HTTP streaming

Streaming is when part of a message is acted upon without knowing the rest.
An HTTP message (request or response) consists of the following parts:

- Message head: A start line with mandatory metadata about the message,
  i.e path of a request or status of a response;
  plus additional metadata in the form of headers, such as `content-type`.
- Message fragment: A part of the message body,
  there may be none up to an unlimited number of these fragments.
- Message tail: The end of the message,
  which may include optional metadata in the form of trailers.

An HTTP streaming server is a long running process,
which can process HTTP message parts, as well as erlang messages from the application.

The `Raxx.Server` is a behaviour to define such a server.
An implementation of this behaviour instructs a process how to interact with a client.

## The Raxx Server

A Raxx server module needs to implement 4 callbacks.
There are 3 callbacks to handle HTTP parts from the client.
The final callback is for handling messages issued from other application processes.

- `handle_headers/2`
- `handle_fragment/2`
- `handle_trailer/2`
- `handle_info/2`

Acceptable return types are the same for every callback in this behaviour.
Returned can be a tuple consisting of message parts to the client and the servers new state or a complete response.
That is the end of the servers interaction with a client.

i.e.

To send some more data:
```elixir
def handle_fragment(fragment, state) do
  # ... processing
  {[Raxx.fragment("Some data")], new_state}
end
```

To not send any data but keep running:
```elixir
def handle_fragment(fragment, state) do
  # ... processing
  {[], new_state}
end
```

Once a complete response is sent the server process will be terminated.
Therefore a full response can be sent without setting a new state.
```elixir
def handle_fragment(fragment, state) do
  # ... processing
  Raxx.response(:no_content)
end
```

### Simplicity and purity

In the original implementation of Raxx the callback implementation could be pure functions.
I asserted that [using pure functions made application code simpler](file:///home/peter/Projects/Tokumei/app/doc/why-raxx.html#purity), and easier to test.

This update to Raxx keeps callbacks pure.

*This is exactly the pattern of a `GenServer`,
where all side effects, such as replying to a call, can be represented in the return values.*

*My concern with the plug interface has always been that certain things can only be achieved by directly causing side effects from within application code.
It is my opinion that this leads to much of the complexity of the `Plug.Conn` object,*

## Examples

### Client streaming data

Naive server to save upload files to an assets directory.

```elixir
defmodule FileUpload do
  use Raxx.Server

  def handle_headers(%{method: :PUT, body: true, path: ["assets", name]}, _config) do
    {:ok, io_device} = File.open("assets/#{name}")
    {[], {:file, device}}
  end

  def handle_fragment(fragment, state = {:file, device}) do
    IO.write(device, fragment)
    {[], state}
  end

  def handle_trailers(_trailers, state) do
    Raxx.response(:see_other)
    |> Raxx.set_header("location", "/")
  end
end
```

### Server streaming response

This server will join a chatroom upon receiving a client.
It will then stream data to that client as messages are published to the chatroom.

```elixir
defmodule SubscribeToMessages do
  use Raxx.Server

  def handle_headers(_request, _config) do
    {:ok, _} = ChatRoom.join()
    Raxx.response(:ok)
    |> Raxx.set_header("content-type", "text/plain")
    |> Raxx.set_body(true)
  end

  def handle_info({:publish, data}, config) do
    {[Raxx.fragment(data)], config}
  end
end
```

## Canonical message

A stream of parts belongs to a single request or response.
The body of a message is considered the same body regardless of the fragments it is separated into.

The simple request response model used in Rack (and previously Raxx) is just a special case
where each stream has one part.

To make it easer to work with HTTP messages Raxx supports a canonical view for complete HTTP messages.

The body of a request (or response) can be a boolean, or the full body as a binary.
This allows a single request to be represented as a single object or a list of parts.

In this example these two representations are of the same request.
```elixir
streamed_request = [
  %Raxx.Response{status: 200, body: true},
  %Raxx.Fragment{data: "Hello, "},
  %Raxx.Fragment{data: "World!"},
  %Raxx.Trailer{headers: []}
]

complete_request = %Raxx.Response{status: 200, headers: [], body: "Hello, World!"}
```

Note in a `Raxx.Server` `handle_headers/2` is always called as soon as the request head has been read.
Therefore the request passed to this callback will always have a boolean value for the body.

A server can collapse the parts of a request into its cannonical version.
This could be done before executing any business logic in some cases.
This might be the simplest solution for a JSON API where neither request or response is ever very large.

This allows simple behaviour to have a simple implementation, without making working with streams harder.

A simple server where all the requests are collapsed before being handled could look like the following:

```elixir
defmodule Raxx.SimpleServer do
  use Raxx.SimpleServer

  # Not a Raxx.Server callback
  def handle_request(request, config) do
    # Work with request and config
    Raxx.response(:ok)
  end

  # When no body already a complete request
  def handle_headers(request = %{body: false}, config) do
    handle_request(request, config)
  end

  # Body expected start an empty buffer to collect data
  def handle_headers(request = %{body: true}, config) do
    buffer = ""
    {[], {request, buffer, config}}
  end

  def handle_fragment(data, {request, buffer, config}) do
    {[], {request, buffer <> data, config}}
  end

  # Always called for a request that has a body
  def handle_trailers(trailers, {request = %{headers: headers}, body, config}) do
    complete_headers = headers ++ trailers
    request = %{request | headers: complete_headers, body: body}
    handle_request(request, config)
  end
end
```
