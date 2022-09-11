defmodule StocksBot do
  use GenServer
  @basic_url "https://api.telegram.org/bot" <> "86656441:AAHqpSUvxPPnkZv_9DcFb8ogZQNjocKwegs"

  def start_link(args) do
    GenServer.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  @impl true
  def init(:ok) do
    get_updates()
    {:ok, %{}}
  end

  def get_updates(offset \\ nil) do
    with {:ok, %HTTPoison.Response{status_code: 200, body: body}} =
           updates_url(offset) |> HTTPoison.get(),
         {:ok, data} = Jason.decode(body) do

      parse_messages(data["result"])
      |> get_last_update_id()
      |> get_updates()
    end
  end

  defp parse_messages(messages) do
    Enum.each(messages, fn message ->
      answer_to_message(message)
    end)

    messages
  end

  defp get_last_update_id([]), do: nil

  defp get_last_update_id(messages) do
    List.last(messages) |> Map.fetch!("update_id")
  end

  defp updates_url(_offset = nil) do
    @basic_url <> "/getUpdates"
  end

  defp updates_url(offset) do
    @basic_url <> "/getUpdates?offset=#{offset + 1}"
  end

  defp answer_to_message(message) do
    %{
      "message" => %{
        "chat" => %{"id" => chat_id},
        "text" => original_text
      }
    } = message

    answer = %{
      text: "Hello: #{original_text}",
      chat_id: chat_id
    }

    HTTPoison.post(
      @basic_url <> "/sendMessage",
      Jason.encode!(answer),
      [{"Content-Type", "application/json"}]
    )
  end
end