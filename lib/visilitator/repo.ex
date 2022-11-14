defmodule Visilitator.Repo do
  @moduledoc false
  use Ecto.Repo,
    otp_app: :visilitator,
    adapter: Ecto.Adapters.Postgres
end
