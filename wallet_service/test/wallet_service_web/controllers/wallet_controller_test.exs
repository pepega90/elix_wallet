defmodule WalletServiceWeb.WalletControllerTest do
  use WalletServiceWeb.ConnCase

  import WalletService.WalletsFixtures

  alias WalletService.Wallets.Wallet

  @create_attrs %{
    balance: 120.5,
    user_id: 42
  }
  @update_attrs %{
    balance: 456.7,
    user_id: 43
  }
  @invalid_attrs %{balance: nil, user_id: nil}

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  describe "index" do
    test "lists all wallets", %{conn: conn} do
      conn = get(conn, ~p"/api/wallets")
      assert json_response(conn, 200)["data"] == []
    end
  end

  describe "create wallet" do
    test "renders wallet when data is valid", %{conn: conn} do
      conn = post(conn, ~p"/api/wallets", wallet: @create_attrs)
      assert %{"id" => id} = json_response(conn, 201)["data"]

      conn = get(conn, ~p"/api/wallets/#{id}")

      assert %{
               "id" => ^id,
               "balance" => 120.5,
               "user_id" => 42
             } = json_response(conn, 200)["data"]
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post(conn, ~p"/api/wallets", wallet: @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "update wallet" do
    setup [:create_wallet]

    test "renders wallet when data is valid", %{conn: conn, wallet: %Wallet{id: id} = wallet} do
      conn = put(conn, ~p"/api/wallets/#{wallet}", wallet: @update_attrs)
      assert %{"id" => ^id} = json_response(conn, 200)["data"]

      conn = get(conn, ~p"/api/wallets/#{id}")

      assert %{
               "id" => ^id,
               "balance" => 456.7,
               "user_id" => 43
             } = json_response(conn, 200)["data"]
    end

    test "renders errors when data is invalid", %{conn: conn, wallet: wallet} do
      conn = put(conn, ~p"/api/wallets/#{wallet}", wallet: @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "delete wallet" do
    setup [:create_wallet]

    test "deletes chosen wallet", %{conn: conn, wallet: wallet} do
      conn = delete(conn, ~p"/api/wallets/#{wallet}")
      assert response(conn, 204)

      assert_error_sent 404, fn ->
        get(conn, ~p"/api/wallets/#{wallet}")
      end
    end
  end

  defp create_wallet(_) do
    wallet = wallet_fixture()
    %{wallet: wallet}
  end
end
