defmodule Tokumei.Static do
  @moduledoc """
  Generate routes to server static assets

  This module will serve a file of static content.
  Configure the static directory by setting the `@static` variable.

      defmodule MyApp.Router do
        use Tokumei.NotFound
        use Tokumei.Static

        @static "./public"
      end

  *build on top of `Raxx.Static`, TODO passing options such as pattern of files to serve as configuration*
  static to assume "./public"
  static needs to have an upper limit on file size
  """

  defmacro __using__(_opts) do
    quote do
      require Raxx.Static

      @static nil

      @before_compile unquote(__MODULE__)
    end
  end

  defmacro __before_compile__(_env) do
    quote do
      defoverridable [handle_request: 2]

      if @static do
        @external_resource @static
        Raxx.Static.serve_dir(@static)
      end

      def handle_request(request, config) do
        super(request, config)
      end
    end
  end
end
