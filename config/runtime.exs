import Config

if config_env() == :prod do
  # I assume floating point representation from 0 to 1 is acceptable for representing this value
  default_fulfillment_overhead_percentage = "0.15"

  {parsed_fulfillment_overhead_percentage, ""} =
    Float.parse(
      System.get_env("FULFILLMENT_OVERHEAD_PERCENTAGE") || default_fulfillment_overhead_percentage
    )

  config :visilitator, Visilitator.Transaction,
    fulfillment_overhead_percentage: parsed_fulfillment_overhead_percentage

  config :visilitator, Visilitator.Repo,
    username: System.get_env("DB_USERNAME", "postgres"),
    password: System.fetch_env!("DB_PASSWORD"),
    database: System.get_env("DB_NAME", "visilitator"),
    hostname: System.get_env("DB_HOST", "postgres")

  config :visilitator, Visilitator.Broadway.CreateAccount,
    queue: System.get_env("QUEUE_CREATE_ACCOUNT", "create_account")

  config :visilitator, Visilitator.Broadway.RequestVisit,
    queue: System.get_env("QUEUE_REQUEST_VISIT", "request_visit")

  config :visilitator, Visilitator.Broadway.FulfillVisit,
    queue: System.get_env("QUEUE_FULFILL_VISIT", "fulfill_visit")

  config :visilitator, Visilitator.Application,
    enable_broadway:
      System.get_env("ENABLE_BROADWAY", "true") |> String.downcase() |> String.to_existing_atom()

  rabbitmq_pass =
    if System.get_env("ENABLE_BROADWAY", "true")
       |> String.downcase()
       |> String.to_existing_atom() == true do
      System.fetch_env!("RABBITMQ_PASSWORD")
    else
      System.get_env("RABBITMQ_PASSWORD", "")
    end

  config :visilitator, :rabbitmq,
    host: System.get_env("RABBITMQ_HOST", "rabbitmq"),
    username: System.get_env("RABBITMQ_USERNAME", "rmq"),
    password: rabbitmq_pass,
    producer: BroadwayRabbitMQ.Producer

  config :logger,
    backends: [:console],
    level: System.get_env("LOG_LEVEL", "info") |> String.downcase() |> String.to_existing_atom()
end

if config_env() == :test do
  config :visilitator, Visilitator.Repo,
    username: System.get_env("DB_USERNAME", "postgres"),
    password: System.get_env("DB_PASSWORD", "pg"),
    database: System.get_env("DB_NAME", "visilitator"),
    hostname: System.get_env("DB_HOST", "localhost"),
    pool: Ecto.Adapters.SQL.Sandbox

  config :visilitator, Visilitator.Broadway.CreateAccount,
    queue: System.get_env("QUEUE_CREATE_ACCOUNT", "create_account")

  config :visilitator, Visilitator.Broadway.RequestVisit,
    queue: System.get_env("QUEUE_REQUEST_VISIT", "request_visit")

  config :visilitator, Visilitator.Broadway.FulfillVisit,
    queue: System.get_env("QUEUE_FULFILL_VISIT", "fulfill_visit")

  config :visilitator, :rabbitmq,
    host: System.get_env("RABBITMQ_HOST", "rabbitmq"),
    username: System.get_env("RABBITMQ_USERNAME", "rmq"),
    password: System.get_env("RABBITMQ_PASSWORD", "rmq"),
    producer: Broadway.DummyProducer

  config :visilitator, Visilitator.Application,
    enable_broadway:
      System.get_env("ENABLE_BROADWAY", "false") |> String.downcase() |> String.to_existing_atom()

  config :logger,
    backends: [:console],
    level: System.get_env("LOG_LEVEL", "notice") |> String.downcase() |> String.to_existing_atom()
end
