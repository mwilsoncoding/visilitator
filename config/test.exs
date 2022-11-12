import Config

config :visilitator, Visilitator.Repo,
  username: "postgres",
  password: "pg",
  database: "postgres",
  hostname: "127.0.0.1",
  pool: Ecto.Adapters.SQL.Sandbox
