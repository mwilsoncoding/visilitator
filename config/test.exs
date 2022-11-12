import Config

config :visilitator, Visilitator.Repo,
  username: "postgres",
  password: "pg",
  database: "postgres",
  hostname: "localhost",
  pool: Ecto.Adapters.SQL.Sandbox
