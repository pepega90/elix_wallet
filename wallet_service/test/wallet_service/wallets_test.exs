defmodule WalletService.WalletsTest do
  use WalletService.DataCase

  alias WalletService.Wallets

  describe "wallets" do
    alias WalletService.Wallets.Wallet

    import WalletService.WalletsFixtures

    @invalid_attrs %{balance: nil, user_id: nil}

    test "list_wallets/0 returns all wallets" do
      wallet = wallet_fixture()
      assert Wallets.list_wallets() == [wallet]
    end

    test "get_wallet!/1 returns the wallet with given id" do
      wallet = wallet_fixture()
      assert Wallets.get_wallet!(wallet.id) == wallet
    end

    test "create_wallet/1 with valid data creates a wallet" do
      valid_attrs = %{balance: 120.5, user_id: 42}

      assert {:ok, %Wallet{} = wallet} = Wallets.create_wallet(valid_attrs)
      assert wallet.balance == 120.5
      assert wallet.user_id == 42
    end

    test "create_wallet/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Wallets.create_wallet(@invalid_attrs)
    end

    test "update_wallet/2 with valid data updates the wallet" do
      wallet = wallet_fixture()
      update_attrs = %{balance: 456.7, user_id: 43}

      assert {:ok, %Wallet{} = wallet} = Wallets.update_wallet(wallet, update_attrs)
      assert wallet.balance == 456.7
      assert wallet.user_id == 43
    end

    test "update_wallet/2 with invalid data returns error changeset" do
      wallet = wallet_fixture()
      assert {:error, %Ecto.Changeset{}} = Wallets.update_wallet(wallet, @invalid_attrs)
      assert wallet == Wallets.get_wallet!(wallet.id)
    end

    test "delete_wallet/1 deletes the wallet" do
      wallet = wallet_fixture()
      assert {:ok, %Wallet{}} = Wallets.delete_wallet(wallet)
      assert_raise Ecto.NoResultsError, fn -> Wallets.get_wallet!(wallet.id) end
    end

    test "change_wallet/1 returns a wallet changeset" do
      wallet = wallet_fixture()
      assert %Ecto.Changeset{} = Wallets.change_wallet(wallet)
    end
  end
end
