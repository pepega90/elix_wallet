defmodule UserServiceWeb.UserController do
  use UserServiceWeb, :controller

  alias UserService.Users
  alias UserService.Users.User
  alias UserService.Publisher
  alias UserService.WalletHandler
  alias UserService.TransactionHandler

  action_fallback(UserServiceWeb.FallbackController)

  def create(conn, body) do
    with {:ok, %User{} = user} <- Users.create_user(body) do
      # when create user, it automatically create this wallet too
      Publisher.publish_message(
        Jason.encode!(%{user_id: user.id, name: user.name, event: "add wallet"})
      )

      conn
      |> put_status(:created)
      |> put_resp_header("location", ~p"/api/users/#{user}")
      |> json(%{user: user})
    end
  end

  def show(conn, %{"id" => id}) do
    user = Users.get_user!(id)

    Publisher.publish_message(Jason.encode!(%{user_id: user.id, event: "get wallet"}))
    Publisher.publish_message(Jason.encode!(%{user_id: user.id, event: "get transaction"}))

    wallet_task = Task.async(fn -> await_wallet_response(user.id) end)
    transactions_task = Task.async(fn -> await_transaction_response(user.id) end)

    wallet = Task.await(wallet_task)
    transactions = Task.await(transactions_task)

    json(conn, %{user: user, wallet_balance: wallet, list_transaction: transactions})
  end

  defp await_wallet_response(message_id, retries \\ 5) do
    case WalletHandler.get_wallet(message_id) do
      nil when retries > 0 ->
        :timer.sleep(200)
        await_wallet_response(message_id, retries - 1)

      wallet ->
        wallet
    end
  end

  defp await_transaction_response(user_id, retries \\ 5) do
    case TransactionHandler.get_transaction(user_id) do
      nil when retries > 0 ->
        :timer.sleep(200)
        await_transaction_response(user_id, retries - 1)

      transactions ->
        transactions
    end
  end

  def topup(conn, %{"user_id" => user_id, "amount" => amount}) do
    Publisher.publish_message(Jason.encode!(%{user_id: user_id, amount: amount, event: "top up"}))
    json(conn, %{message: "successfully top up"})
  end

  def transfer(conn, %{"from_user_id" => from_id, "to_user_id" => to_id, "amount" => amount}) do
    Publisher.publish_message(
      Jason.encode!(%{
        from_id: from_id,
        to_id: to_id,
        amount: amount,
        event: "transfer"
      })
    )

    from_user = Users.get_user!(from_id)
    to_user = Users.get_user!(to_id)

    json(conn, %{
      message:
        "successfully transfer money with amount #{amount} from #{from_user.name} to #{to_user.name} "
    })
  end
end
