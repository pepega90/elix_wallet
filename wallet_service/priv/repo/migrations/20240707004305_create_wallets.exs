defmodule WalletService.Repo.Migrations.CreateWallets do
  use Ecto.Migration

  def change do
    create table(:wallets) do
      add :user_id, :integer
      add :balance, :float

      timestamps(type: :utc_datetime)
    end
  end
end
