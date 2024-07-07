defmodule UserService.BroadwayPipeline do
  use Broadway

  alias Broadway.Message
  alias UserService.WalletHandler
  alias UserService.TransactionHandler

  def start_link(_opts) do
    Broadway.start_link(__MODULE__,
      name: __MODULE__,
      producer: [
        module:
          {BroadwayRabbitMQ.Producer,
           queue: "user_queue",
           connection: [
             host: "localhost",
             username: "guest",
             password: "guest"
           ]}
      ],
      processors: [
        default: [concurrency: 10]
      ]
    )
  end

  @impl true
  def handle_message(_, %Broadway.Message{data: data} = message, _) do
    case Jason.decode(data) do
      {:ok, %{"balance" => balance, "user_id" => user_id, "event" => "get wallet"}} ->
        IO.puts("[x] Received messsage get user wallet")
        WalletHandler.store_wallet(user_id, balance)

      {:ok, %{"user_id" => user_id, "data" => data, "event" => "get transaction"}} ->
        list_trans = data |> Jason.decode!()
        TransactionHandler.store_transaction(user_id, list_trans)
        IO.puts("[x] Received messsage user list transaction")

      _ ->
        IO.puts("Invalid message format")
    end

    message
  end
end
