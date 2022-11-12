import Config

config :visilitator, Visilitator.Repo,
  database: "postgres",
  username: "postgres",
  password: "pg",
  hostname: "pg"

config :visilitator,
  ecto_repos: [Visilitator.Repo]

config :visilitator, Visilitator.User, fulfillment_overhead_percentage: 0.15

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{config_env()}.exs"
