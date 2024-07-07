defmodule UserService.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      UserServiceWeb.Telemetry,
      UserService.Repo,
      {DNSCluster, query: Application.get_env(:user_service, :dns_cluster_query) || :ignore},
      {Phoenix.PubSub, name: UserService.PubSub},
      # Start a worker by calling: UserService.Worker.start_link(arg)
      # {UserService.Worker, arg},
      # Start to serve requests, typically the last entry
      UserServiceWeb.Endpoint,
      UserService.WalletHandler,
      UserService.TransactionHandler,
      UserService.BroadwayPipeline
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: UserService.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    UserServiceWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
