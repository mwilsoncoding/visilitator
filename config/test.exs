import Config

config :visilitator, Visilitator.Repo,
  username: "postgres",
  password: "pg",
  database: "visilitator",
  hostname: "localhost",
  pool: Ecto.Adapters.SQL.Sandbox
