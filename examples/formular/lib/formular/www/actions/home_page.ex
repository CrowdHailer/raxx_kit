defmodule Formular.WWW.Actions.HomePage do
  use Raxx.SimpleServer
  use Formular.WWW.Layout, arguments: [:title]

  @impl Raxx.SimpleServer
  def handle_request(_request = %{method: :GET}, _state) do
    title = "Raxx.Kit"

    response(:ok)
    |> render(title)
  end

  # Could be form or query, could be called Data,
  # This is the form object pattern, a form with a get ends up in a query so maybe still a form?
  # spec
  defmodule Payload do
    use Ecto.Schema

    @primary_key false
    embedded_schema do
      field(:name, :string)
      field(:age, :integer)
    end

    # type spec should point out that name will never be nil
    def from_params(params) do
      import Ecto.Changeset

      %__MODULE__{}
      |> cast(params, __schema__(:fields))
      |> validate_required(:name)
      |> validate_number(:age, greater_than: 0)
      |> apply_action(:insert)
    end
  end

  def handle_request(request = %{method: :POST}, _state) do
    require OK

    OK.for do
      # always works
      params = URI.decode_query(request.body)
      data <- Payload.from_params(params)
    after
      greeting = "Hello, #{data.name}!"

      response(:ok)
      |> render(greeting)
    end
  end

  defprotocol RaxxRespondable do
    def to_response(term)
  end

  # This doesn't really work because you would want to define a different response for the page for each failure kind.
  defimpl RaxxRespondable, for: Ecto.Changeset do
    def to_response(_) do
      Raxx.response(:bad_request)
    end
  end

  # We could update the type spec of handle request to be Raxx.Response | {:ok, Raxx.Response} | {:error, term}
  defoverridable handle_request: 2

  def handle_request(request, state) do
    case super(request, state) do
      response = %Raxx.Response{} ->
        response

      {:ok, response = %Raxx.Response{}} ->
        response

      {:error, response = %Raxx.Response{}} ->
        response

      {:error, term} ->
        RaxxRespondable.to_response(term)
    end
  end

  # case URI.decode_query(request.body) do
  #   data ->
  #     Payload.from_params(data)
  #     |> IO.inspect()
  #
  #     # %{"name" => name} ->
  #     #   greeting = "Hello, #{name}!"
  #     #
  #     #   response(:ok)
  #     #   |> render(greeting)
  #     #
  #     # _ ->
  #     #   response(:bad_request)
  #     #   |> render("Bad Request")
  # end
end
