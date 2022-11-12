import Config

config :visilitator, Visilitator.Repo,
  username: "postgres",
  password: "pg",
  database: "postgres",
  hostname: "postgres",
  pool: Ecto.Adapters.SQL.Sandbox
