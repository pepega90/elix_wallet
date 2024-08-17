# This file is responsible for configuring your application
# and its dependencies with the aid of the Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
import Config

config :user_service, UserService.PromEx,
  manual_metrics_start_delay: :no_delay,
  drop_metrics_groups: [],
  grafana: [
    host: "http://localhost:3000",
    auth_token: "glsa_N8v37UdHuFVrPaHRzqBuWlilO4es2FkB_dc0bfd93",
    upload_dashboard_on_start: true,
    folder_name: "user_service_dashboard",
    annotate_app_lifecycle: true
  ]

config :user_service, UserService.Guardian,
  issuer: "user_service",
  secret_key: "some_secret"

config :user_service,
  ecto_repos: [UserService.Repo],
  generators: [timestamp_type: :utc_datetime]

# Configures the endpoint
config :user_service, UserServiceWeb.Endpoint,
  url: [host: "localhost"],
  adapter: Bandit.PhoenixAdapter,
  render_errors: [
    formats: [json: UserServiceWeb.ErrorJSON],
    layout: false
  ],
  pubsub_server: UserService.PubSub,
  live_view: [signing_salt: "O8fxOOri"]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

config :logger,
  level: :info

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{config_env()}.exs"
