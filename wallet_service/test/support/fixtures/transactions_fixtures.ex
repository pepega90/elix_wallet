defmodule WalletService.TransactionsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `WalletService.Transactions` context.
  """

  @doc """
  Generate a transaction.
  """
  def transaction_fixture(attrs \\ %{}) do
    {:ok, transaction} =
      attrs
      |> Enum.into(%{
        amount: 120.5,
        type: "some type",
        user_id: 42
      })
      |> WalletService.Transactions.create_transaction()

    transaction
  end
end
