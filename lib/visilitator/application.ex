defmodule Visilitator.Application do
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    # Sets up in-memory storage suitable for a PoC/MVP.
    :ets.new(:users, [:named_table, :public])
    :ets.new(:visits, [:named_table, :public])
    :ets.new(:transactions, [:named_table, :public])

    children = []

    opts = [strategy: :one_for_one, name: Visilitator.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
