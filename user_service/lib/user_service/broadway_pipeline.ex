defmodule UserService.BroadwayPipeline do
  use Broadway
  use AMQP

  alias Broadway.Message
  alias UserService.WalletHandler
  alias UserService.TransactionHandler

  require Logger

  @queue_name "user_queue"

  def start_link(_opts) do
    create_queue()

    Broadway.start_link(__MODULE__,
      name: __MODULE__,
      producer: [
        module:
          {BroadwayRabbitMQ.Producer,
           queue: @queue_name,
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

  defp create_queue do
    {:ok, connection} = Connection.open("amqp://guest:guest@localhost:5672")
    {:ok, channel} = Channel.open(connection)
    {:ok, _queue_info} = Queue.declare(channel, @queue_name, durable: true)
    :ok = Channel.close(channel)
    :ok = Connection.close(connection)

    Logger.info("Queue #{@queue_name} created")
  end

  @impl true
  def handle_message(_, %Broadway.Message{data: data} = message, _) do
    case Jason.decode(data) do
      {:ok, %{"balance" => balance, "user_id" => user_id, "event" => "get wallet"}} ->
        Logger.info("Received messsage get user wallet")
        WalletHandler.store_wallet(user_id, balance)

      {:ok, %{"user_id" => user_id, "data" => data, "event" => "get transaction"}} ->
        list_trans = data |> Jason.decode!()
        TransactionHandler.store_transaction(user_id, list_trans)
        Logger.info("Received messsage user list transaction")

      _ ->
        Logger.error("Invalid message format")
    end

    message
  end
end
