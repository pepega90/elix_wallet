defmodule WalletService.Repo do
  use Ecto.Repo,
    otp_app: :wallet_service,
    adapter: Ecto.Adapters.Postgres
end
