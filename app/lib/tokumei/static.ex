defmodule Tokumei.Static do
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

      def handle_request(r, e) do
        super(r, e)
      end
    end
  end
end
