# This file is responsible for configuring your application
# and its dependencies with the aid of the Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
import Config

config :sobelow_dashboard,
  ecto_repos: [SobelowDashboard.Repo],
  generators: [timestamp_type: :utc_datetime]

# Configures the endpoint
config :sobelow_dashboard, SobelowDashboardWeb.Endpoint,
  url: [host: "localhost"],
  adapter: Bandit.PhoenixAdapter,
  render_errors: [
    formats: [json: SobelowDashboardWeb.ErrorJSON],
    layout: false
  ],
  pubsub_server: SobelowDashboard.PubSub,
  live_view: [signing_salt: "0H73TAt1"]

# Configures the mailer
#
# By default it uses the "Local" adapter which stores the emails
# locally. You can see the emails in your browser, at "/dev/mailbox".
#
# For production it's recommended to configure a different adapter
# at the `config/runtime.exs`.
config :sobelow_dashboard, SobelowDashboard.Mailer, adapter: Swoosh.Adapters.Local

# Configures Elixir's Logger
config :logger, :default_formatter,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

config :sobelow_dashboard, Oban,
    engine: Oban.Engines.Basic,
    queues: [default: 15],
    repo: SobelowDashboard.Repo

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{config_env()}.exs"
