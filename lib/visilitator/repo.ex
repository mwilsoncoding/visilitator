defmodule Visilitator.Repo do
  use Ecto.Repo,
    otp_app: :visilitator,
    adapter: Ecto.Adapters.Postgres
end
