# Roadmap

Jotting down ideas for growth path to maturity for this app.

## Phase 1: PoC/MVP

Storage: ETS
UI: IEX
Tests: ExUnit, format, credo
Config: dev
OCI: Dockerfile

## Phase 2: Persistent Storage

Storage: PostgreSQL + Ecto
UI: IEX
Tests: ExUnit, format, credo, dialyzer
Config: dev, test
OCI: Dockerfile
Logging: Logger

## Phase 3: Networking

Storage: PG + Ecto
UI: IEX + AMQP
Tests: ExUnit, format, credo, dialyzer
Config: dev, test, prod
OCI: Dockerfile
Logging: Logger
Async Message handling: Broadway + RabbitMQ

## Phase 4: Front End

Storage: PG + Ecto
UI: Phoenix Web App --AMQP message-> rabbitmq -> Broadway consumer
Tests: ExUnit, format, credo, dialyzer
Config: dev, test, prod
OCI: Dockerfile
Logging: Logger
Async Message handling: Broadway + RabbitMQ
Deployment: K8s

## Phase 5: Cloud Optimizations

PromEx for metrics in prometheus + grafana
LiveView for JS dependency reduction/elimination
