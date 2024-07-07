defmodule WalletService.Repo.Migrations.CreateTransactions do
  use Ecto.Migration

  def change do
    create table(:transactions) do
      add :user_id, :integer
      add :type, :string
      add :amount, :float

      timestamps(type: :utc_datetime)
    end
  end
end
