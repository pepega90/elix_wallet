defmodule UserServiceWeb.UserController do
  use UserServiceWeb, :controller

  alias UserService.Users
  alias UserService.Users.User
  alias UserService.Publisher
  alias UserService.WalletHandler
  alias UserService.TransactionHandler
  alias UserService.Guardian

  action_fallback(UserServiceWeb.FallbackController)

  def login(conn, %{"email" => email, "password" => password}) do
    case Users.authenticate_user(email, password) do
      {:ok, user} ->
        {:ok, token, _claims} = Guardian.encode_and_sign(user)

        conn
        |> json(%{token: token})

      {:error, :unauthorized} ->
        conn
        |> put_status(:unauthorized)
        |> json(%{message: :unauthorize})
    end
  end

  defp get_current_user(conn) do
    user = Guardian.Plug.current_resource(conn)
    user
  end

  def create(conn, body) do
    with {:ok, %User{} = user} <- Users.create_user(body) do
      # when create user, it automatically create this wallet too
      Publisher.publish_message(
        Jason.encode!(%{user_id: user.id, name: user.name, event: "add wallet"}),
        "wallet_queue"
      )

      conn
      |> put_status(:created)
      |> put_resp_header("location", ~p"/api/users/#{user}")
      |> json(%{user: user})
    end
  end

  def show(conn, %{"id" => id}) do
    user = Users.get_user!(id)
    get_current_user(conn) |> IO.inspect()

    Publisher.publish_message(
      Jason.encode!(%{user_id: user.id, event: "get wallet"}),
      "wallet_queue"
    )

    Publisher.publish_message(
      Jason.encode!(%{user_id: user.id, event: "get transaction"}),
      "wallet_queue"
    )

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

  def topup(conn, %{"amount" => amount}) do
    user = get_current_user(conn)

    Publisher.publish_message(
      Jason.encode!(%{user_id: user.id, amount: amount, event: "top up"}),
      "wallet_queue"
    )

    json(conn, %{message: "successfully top up"})
  end

  def transfer(conn, %{"to_user_id" => to_id, "amount" => amount}) do
    user = get_current_user(conn)

    Publisher.publish_message(
      Jason.encode!(%{
        from_id: user.id,
        to_id: to_id,
        amount: amount,
        event: "transfer"
      }),
      "wallet_queue"
    )

    to_user = Users.get_user!(to_id)

    json(conn, %{
      message:
        "successfully transfer money with amount #{amount} from #{user.name} to #{to_user.name} "
    })
  end
end
