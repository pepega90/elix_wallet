defmodule WalletService.BroadwayPipeline do
  use Broadway
  use AMQP

  require Logger

  alias Broadway.Message
  alias WalletService.Wallets
  alias WalletService.Transactions
  alias WalletService.Repo
  alias WalletService.Publisher

  @queue_name "wallet_queue"

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
      {:ok, %{"name" => name, "user_id" => user_id, "event" => "add wallet"}} ->
        Logger.info("Received messsage created user wallet")
        Wallets.create_wallet(%{user_id: user_id, balance: 0})

      {:ok, %{"user_id" => user_id, "event" => "get wallet"}} ->
        Logger.info("Received message get wallet")
        find_wallet = WalletService.Wallets.get_wallet_by_user_id(user_id)

        if find_wallet do
          wallet_data = Map.put(find_wallet, :balance, round(find_wallet.balance))

          Publisher.publish_message(
            Jason.encode!(%{
              balance: wallet_data.balance,
              user_id: wallet_data.user_id,
              event: "get wallet"
            }),
            "user_queue"
          )
        else
          Logger.info("Wallet not found for user_id: #{user_id}")
        end

      {:ok, %{"user_id" => user_id, "amount" => amount, "event" => "top up"}} ->
        Repo.transaction(fn ->
          case Wallets.top_up_wallet(user_id, amount) do
            {:ok, wallet} ->
              case Transactions.create_transaction(%{
                     user_id: user_id,
                     type: "Top Up",
                     amount: amount
                   }) do
                {:ok, _transaction} ->
                  Logger.info("Wallet topped up for user_id: #{user_id}")
                  {:ok, wallet}

                {:error, reason} ->
                  Logger.info("Failed to create transaction: #{reason}")
                  Repo.rollback(reason)
              end

            {:error, reason} ->
              Logger.info("Failed to top up wallet: #{reason}")
              Repo.rollback(reason)
          end
        end)

      {:ok, %{"from_id" => from_id, "to_id" => to_id, "amount" => amount, "event" => "transfer"}} ->
        Repo.transaction(fn ->
          from_wallet = WalletService.Wallets.get_wallet_by_user_id(from_id)
          to_wallet = WalletService.Wallets.get_wallet_by_user_id(to_id)

          from_balance = from_wallet.balance - amount
          to_balance = to_wallet.balance + amount

          from_changeset =
            from_wallet
            |> Ecto.Changeset.change()
            |> Ecto.Changeset.put_change(:balance, from_balance)

          to_changeset =
            to_wallet
            |> Ecto.Changeset.change()
            |> Ecto.Changeset.put_change(:balance, to_balance)

          with {:ok, _} <- Repo.update(from_changeset),
               {:ok, _} <- Repo.update(to_changeset) do
            Transactions.create_transaction(%{user_id: from_id, type: "Transfer", amount: amount})
            Logger.info("Transfer successful")
          else
            {:error, reason} -> Repo.rollback(reason)
          end
        end)

      {:ok, %{"user_id" => user_id, "event" => "get transaction"}} ->
        list_trans = Transactions.list_transactions_by_user_id(user_id)

        updated_list_trans =
          list_trans
          |> Enum.map(fn trans ->
            Map.put(trans, :amount, round(trans.amount))
          end)

        Publisher.publish_message(
          Jason.encode!(%{
            user_id: user_id,
            data: Jason.encode!(updated_list_trans),
            event: "get transaction"
          }),
          "user_queue"
        )

      _ ->
        Logger.error("Invalid message format")
    end

    message
  end
end
