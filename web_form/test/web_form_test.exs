defprotocol WebForm.Input do
  def take(field, mount, map)

  def check_blank(field, raw)
end

defmodule WebForm.Input.Text do
  defstruct [:pattern]

  def new(opts \\ []) do
    struct(__MODULE__, opts)
  end
end

defimpl WebForm.Input, for: WebForm.Input.Text do
  def take(self, key, map) do
    {:ok, raw} = Map.fetch(map, "#{key}")
    WebForm.Input.check_blank(self, raw)
    |> IO.inspect
    {key, {:ok, :out}}
  end
end
defimpl WebForm.Input, for: Any do
  def check_blank(self, x) do
    IO.inspect(self)
  end
end


defmodule Input.Text do
  defmacro __using__(_) do
    quote do
      def take(key, options, map) do
        {:ok, raw} = Map.fetch(map, "#{key}")
        {key, coerce(raw, options)}
      end
      def coerce(raw, opts) do
        IO.inspect(raw)

        raw
      end
      defoverridable [take: 3, coerce: 2]
    end
  end
end

defmodule MyApp.Fields do
  defmodule Email do
    use Input.Text

    def coerce(raw, _) do
      {:email, raw}
    end
  end

  def username do
    WebForm.Input.Text.new(pattern: ~r/[a-z]+/)
  end
end

defmodule MyApp.SignUpForm do

  def validate(form) do
    validator = %{
      username: {MyApp.Fields.Email, []},
      other: MyApp.Fields.Email
    }

    for {key, validator} <- validators do
      case validator do
        {field, options} ->
          field.take(key, options, form)
      end
    end
  end
end


defmodule WebFormTest do
  use ExUnit.Case
  doctest WebForm

  test "the truth" do
    form = %{"username" => "baz"}
    MyApp.SignUpForm.validate(form)
    |> IO.inspect
  end
end
