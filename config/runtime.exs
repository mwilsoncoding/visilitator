import Config

if config_env() == :prod do
  # I assume floating point representation from 0 to 1 is acceptable for representing this value
  default_fulfillment_overhead_percentage = "0.15"

  {parsed_fulfillment_overhead_percentage, ""} =
    Float.parse(
      System.get_env("FULFILLMENT_OVERHEAD_PERCENTAGE") || default_fulfillment_overhead_percentage
    )

  config :visilitator, Visilitator.User,
    fulfillment_overhead_percentage: parsed_fulfillment_overhead_percentage

  config :visilitator, Visilitator.Repo,
    username: System.get_env("DB_USERNAME", "postgres"),
    password: System.fetch_env!("DB_PASSWORD"),
    database: System.get_env("DB_NAME", "visilitator"),
    hostname: System.get_env("DB_HOST", "pg")
end

if config_env() == :test do
  config :visilitator, Visilitator.Repo,
    username: System.get_env("DB_USERNAME", "postgres"),
    password: System.get_env("DB_PASSWORD", "pg"),
    database: System.get_env("DB_NAME", "visilitator"),
    hostname: System.get_env("DB_HOST", "localhost"),
    pool: Ecto.Adapters.SQL.Sandbox
end
