# Why Raxx

- *[CrowdHailer](http://github.com/crowdhailer/) - 03 March 2017*

---

**Why is [Tokumei](https://hexdocs.pm/tokumei/readme.html) built on top of [Raxx](https://github.com/crowdhailer/raxx)?**

In summary: semantics, simplicity, history and purity (in that order).

## Semantics

HTTP is a stateless request/response protocol.
All the information required to generate a response is contained within the request.

```
client -> request -> server -> response -> client
```
*This picture deliberately avoids websockets etc, we will deal with that later.*

The job of a server is to transform an incoming request to an outgoing response.
A server is the combination of behaviour and configuration.
Raxx aims to match these semantics as closely as possible.
To be a server a module only has to implement a `handle_request/2` function.
This function takes an incoming request (plus configuration) and returns the response

Given a server module `MyApp`.

```elixir
response = MyApp.handle_request(request, config)
```

## Simplicity

There is always an advantage to using the simplest sufficient interface.
This advantage is a reduced complexity overhead compared to any more general purpose interface.

A request/response model is so simple that the HTTP/2 design goals included "Maintain high-level compatibility with HTTP 1.1".
This included preserving the semantics that a single request generates a single response.

HTTP/2's main improvement is increased efficiency of the transport of many requests and responses.

## History

Many other webserver interfaces have the same semantics as Raxx, notably [Ruby's Rack interface](http://rack.github.io/).
Projects like Rack have been incredibly effective at marrying applications to a range of servers.

The increasing pre-eminence of more sophisticated client server communication has highlighted areas where these interfaces are not suitable.
However it has not diminished their effectiveness in areas where they are suitable.

These projects are also established and understood by a large number of developers.
This familiarity is valuable for the many projects that are built today without websockets etc.

## Purity

Functional purity can be an academic consideration, certainly it is more important that software is useful than meeting arbitrary standards.

However, the stateless nature of HTTP means that the pure transformation of request to responses is a good model.
The reasonability of pure functions makes working with Raxx servers simple.
For example testing Raxx servers can be done quickly with out any support framework.

```elixir
test "The home page returns ok" do
  request = %{path: [], method: :GET}
  response = MyApp.handle_request(request, [])
  assert %{status: 200, body: "Hello, world!"} = response
end
```

## Drawbacks

Where are the drawbacks to Raxx?
The answer is obvious.
Anywhere the request/response model is inaccurate, Raxx will be unhelpful.

In web applications this model normally breaks down for one of two reasons:
1. The request and/or response is too large to be considered a single unit for transformation.
  i.e. A HD video as response or an upload of all your holiday photos as a request.
2. A single request does not lead to a single response.
  i.e. websockets and server sent events

So how do we deal with the above shortcomings.

First, it is worth checking if either of these is an issue at all for your application.
- A restful JSON API has no concept of streaming and messages are not likely to be that large.
- As server capability increases, larger responses can be handled in memory and optimisations for sending them can be arranged at a lower level than application code.

Second, use the right tool for the right job.
- Do you really want massive uploads going through your application? [S3 allows for direct uploads](http://docs.aws.amazon.com/AmazonS3/latest/dev/UsingHTTPPOST.html)
- Do you really want to serve huge images from your application? Use a CDN
- Streaming is such a different concept it might make sense to develop with a [separate interface](https://github.com/elixir-lang/plug).
