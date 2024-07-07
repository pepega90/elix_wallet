defmodule WalletService.WalletsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `WalletService.Wallets` context.
  """

  @doc """
  Generate a wallet.
  """
  def wallet_fixture(attrs \\ %{}) do
    {:ok, wallet} =
      attrs
      |> Enum.into(%{
        balance: 120.5,
        user_id: 42
      })
      |> WalletService.Wallets.create_wallet()

    wallet
  end
end
