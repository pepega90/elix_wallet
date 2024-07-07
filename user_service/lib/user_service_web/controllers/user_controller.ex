defmodule UserServiceWeb.UserController do
  use UserServiceWeb, :controller

  alias UserService.Users
  alias UserService.Users.User
  alias UserService.Publisher
  alias UserService.WalletHandler
  alias UserService.TransactionHandler

  action_fallback(UserServiceWeb.FallbackController)

  # def index(conn, _params) do
  #   users = Users.list_users()
  #   render(conn, :index, users: users)
  # end

  # TODO: transfer from_user to to_user

  def create(conn, body) do
    with {:ok, %User{} = user} <- Users.create_user(body) do
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
    wallet = await_wallet_response(user.id)
    transactions = await_transaction_response(user.id)
    # render(conn, :show, user: user, wallet: wallet)
    json(conn, %{user: user, wallet_balance: wallet, list_transaction: transactions})
  end

  defp await_wallet_response(message_id) do
    :timer.sleep(500)
    WalletHandler.get_wallet(message_id)
  end

  defp await_transaction_response(user_id) do
    :timer.sleep(500)
    TransactionHandler.get_transaction(user_id)
  end

  def topup(conn, %{"user_id" => user_id, "amount" => amount}) do
    Publisher.publish_message(Jason.encode!(%{user_id: user_id, amount: amount, event: "top up"}))
    json(conn, %{message: "successfully top up"})
  end

  # def update(conn, %{"id" => id, "user" => user_params}) do
  #   user = Users.get_user!(id)

  #   with {:ok, %User{} = user} <- Users.update_user(user, user_params) do
  #     render(conn, :show, user: user)
  #   end
  # end

  # def delete(conn, %{"id" => id}) do
  #   user = Users.get_user!(id)

  #   with {:ok, %User{}} <- Users.delete_user(user) do
  #     send_resp(conn, :no_content, "")
  #   end
  # end
end
