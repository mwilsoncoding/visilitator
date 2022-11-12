defmodule Visilitator.Application do
  @moduledoc false

  use Application

  @impl true
  @spec start(any, any) :: {:error, any} | {:ok, pid}
  def start(_type, _args) do
    # Sets up in-memory storage suitable for a PoC/MVP.
    :ets.new(:visits, [:named_table, :public])
    :ets.new(:transactions, [:named_table, :public])

    children = [
      Visilitator.Repo
    ]

    opts = [strategy: :one_for_one, name: Visilitator.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
