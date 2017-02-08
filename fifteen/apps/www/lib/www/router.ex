defmodule Fifteen.WWW.Router do
  import Tokumei.Router
  alias Tokumei.Router.{NotImplementedError, MethodNotAllowedError, NotFoundError}
  alias Raxx.Response

  route "/" do
    :GET -> Response.ok("Hi")
  end
end
