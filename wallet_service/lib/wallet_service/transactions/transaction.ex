defmodule WalletService.Transactions.Transaction do
  use Ecto.Schema
  import Ecto.Changeset

  @derive {Jason.Encoder, only: [:type, :amount]}

  schema "transactions" do
    field(:type, :string)
    field(:user_id, :integer)
    field(:amount, :float)

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(transaction, attrs) do
    transaction
    |> cast(attrs, [:user_id, :type, :amount])
    |> validate_required([:user_id, :type, :amount])
  end
end
