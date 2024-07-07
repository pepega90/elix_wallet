defmodule WalletService.Wallets.Wallet do
  use Ecto.Schema
  import Ecto.Changeset

  @derive {Jason.Encoder, only: [:balance, :user_id]}

  schema "wallets" do
    field(:balance, :float)
    field(:user_id, :integer)

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(wallet, attrs) do
    wallet
    |> cast(attrs, [:user_id, :balance])
    |> validate_required([:user_id, :balance])
  end
end
