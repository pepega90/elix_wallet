defmodule WalletService.BroadwayPipeline do
  use Broadway

  alias Broadway.Message
  alias WalletService.Wallets
  alias WalletService.Transactions

  alias WalletService.Publisher

  def start_link(_opts) do
    Broadway.start_link(__MODULE__,
      name: __MODULE__,
      producer: [
        module:
          {BroadwayRabbitMQ.Producer,
           queue: "wallet_queue",
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
      {:ok, %{"name" => name, "user_id" => user_id, "event" => "add wallet"}} ->
        IO.puts("[x] Received messsage created user wallet")
        Wallets.create_wallet(%{user_id: user_id, balance: 0})

      {:ok, %{"user_id" => user_id, "event" => "get wallet"}} ->
        IO.puts("[x] Received message get wallet")
        find_wallet = WalletService.Wallets.get_wallet_by_user_id(user_id)

        if find_wallet do
          wallet_data = Map.put(find_wallet, :balance, round(find_wallet.balance))

          Publisher.publish_message(
            Jason.encode!(%{
              balance: wallet_data.balance,
              user_id: wallet_data.user_id,
              event: "get wallet"
            })
          )
        else
          IO.puts("[x] Wallet not found for user_id: #{user_id}")
        end

      {:ok, %{"user_id" => user_id, "amount" => amount, "event" => "top up"}} ->
        case Wallets.top_up_wallet(user_id, amount) do
          {:ok, _wallet} ->
            Transactions.create_transaction(%{user_id: user_id, type: "Top Up", amount: amount})
            IO.puts("[x] Wallet topped up for user_id: #{user_id}")

          {:error, reason} ->
            IO.puts("[x] Failed to top up wallet: #{reason}")
        end

      {:ok, %{"user_id" => user_id, "event" => "get transaction"}} ->
        list_trans = Transactions.list_transactions_by_user_id(user_id)

        Publisher.publish_message(
          Jason.encode!(%{
            user_id: user_id,
            data: Jason.encode!(list_trans),
            event: "get transaction"
          })
        )

      _ ->
        IO.puts("Invalid message format")
    end

    message
  end
end
