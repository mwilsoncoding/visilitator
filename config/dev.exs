import Config

config :visilitator, Visilitator.Repo,
  username: "postgres",
  password: "pg",
  database: "visilitator",
  hostname: "pg",
  # Comment out the pool if you want to rid yourself of ignorable postgrex connection issues in iex when MIX_ENV=dev
  pool: Ecto.Adapters.SQL.Sandbox

config :visilitator, Visilitator.Broadway.CreateAccount, queue: "create_account"
config :visilitator, Visilitator.Broadway.RequestVisit, queue: "request_visit"
config :visilitator, Visilitator.Broadway.FulfillVisit, queue: "fulfill_visit"

config :visilitator, :rabbitmq,
  username: "rmq",
  password: "rmq",
  host: "rabbitmq",
  producer: BroadwayRabbitMQ.Producer
