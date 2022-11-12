import Config

config :visilitator, Visilitator.Repo,
  username: "postgres",
  password: "pg",
  database: "postgres",
  hostname: "pg",
  pool: Ecto.Adapters.SQL.Sandbox
