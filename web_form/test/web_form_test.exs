defprotocol WebForm.Input do
  def take(data, key, map)
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
    # check_blank(raw)
    {key, {:ok, :out}}
  end
end

defmodule WebForm do

end

defmodule MyApp.Fields do
  def username do
    WebForm.Input.Text.new(pattern: ~r/[a-z]+/)
  end
end

defmodule MyApp.SignUpForm do

  def validate(form) do
    validator = %{username: WebForm.Input.Text.new}

    for {mount, field} <- validator do
      WebForm.Input.take(field, mount, form)
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
