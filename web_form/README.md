# WebForm

**TODO: Add description**

## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed as:

  1. Add `web_form` to your list of dependencies in `mix.exs`:

    ```elixir
    def deps do
      [{:web_form, "~> 0.1.0"}]
    end
    ```

  2. Ensure `web_form` is started before your application:

    ```elixir
    def application do
      [applications: [:web_form]]
    end
    ```


```elixir
defmodule WebForm do
  def coerce(validator, form) do
    for {key, {mod, opts}} <- validator do
      {:ok, raw} = Map.get(form, "#{key}")
      # mod.handle_missing
      case mod.is_blank?(raw) do
        true ->
          blank_response(opts)
        false ->
          mod.coerce(raw)
      end
    end
  end
end

defmodule SomeField do
  def validate(key, opts, form) do
    {:ok, raw} = Map.get(form, "#{key}")
    case mod.is_blank?(raw) do
      true ->
        blank_response(opts)
      false ->
        mod.validate(raw)
    end
  end

  def is_blank?("") do
    true
  end

  def blank_response(%{required: true}) do
    {:error, :x}
  end
  def blank_response(%{default: v}) do
    {:ok, v}
  end

  def validate(raw) do
    check_string(raw, [pattern: ~r//, min_length: 0, max_length: 10])
  end
end

defmodule CreateAccountForm do
  defstruct [
    comment: {TextInput, required: true}
    honorific: {TextInput, default: "Mr"}
    honorific: {TextInput, default: nil}
    honorific: {AvatarInput, default: nil}
  ]
end

defmodule AvatarInput do
  use FileInput, accept: [".jpg", ".png"]
end


defmodule EmailInput do
  use TextInput

  def coerce(email) do
    Email.new(email)
  end
end

defmodule MyFields do
  def email(opts) do
    EmailInput.new(opts)
  end

  def username(opts \\ []) do
    Fields.
  end
end

defmodule LoginForm do
  defstruct [
    email: MyFields.email(requred: true)
  ]

  def validate(form) do
    Webform.coerce(%__MODULE__, form)
    ~>> check_password_confirmation
    ~>> require_terms_checked
  end
end

Field.validate(%Checkbox{true: "on", false: "off"}, "banana")
defmodule SignUpForm do
  use WebForm.Fields
  defstruct [
    # this is what I want to avoid because username gets defined in each form
    username: string(pattern: ~r/[a-z]+/i, min_length: 3, max_length: 25)
    terms: checkbox(true: "on", false: "off")
  ]
end

SignUpForm.validate("username" => "bob")
```


```js
validator = {
  email: maybe(parse_email, null_emai),
  username: required(parse_email)
}

function has_default(alternative){
  return function(value, next){
    if (value.blank) {
      ok(alternative)
    } else {
      next(value)
    }
  }
}
function required(){
  return function(value, next){
    if (value.blank) {
      error("shucks")
    } else {
      next(value)
    }
  }
}
```
