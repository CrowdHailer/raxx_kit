defmodule ContentLength do
  def handle_request(request, {next, nil}) do
    next.(request)
    |> check_length
  end

  defp check_length(response) do
    case Raxx.ContentLength.fetch(response) do
      {:ok, _} ->
        response
      {:error, :field_value_not_specified} ->
        Raxx.ContentLength.set(response, :erlang.iolist_size(response.body))
    end
  end
end
