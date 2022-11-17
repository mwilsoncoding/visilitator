defmodule Visilitator.Application do
  @moduledoc false

  use Application

  require Logger

  @impl true
  @spec start(any, any) :: {:error, any} | {:ok, pid}
  def start(_type, _args) do
    children =
      [
        Visilitator.Repo,
        {K8sProbe,
         port: Application.fetch_env!(:visilitator, __MODULE__) |> Keyword.fetch!(:k8s_probe_port)}
      ]
      |> (fn c ->
            if Application.fetch_env!(:visilitator, __MODULE__)
               |> Keyword.fetch!(:enable_broadway) == true do
              c ++
                [
                  Visilitator.Broadway.CreateAccount,
                  Visilitator.Broadway.RequestVisit,
                  Visilitator.Broadway.FulfillVisit
                ]
            else
              c
            end
          end).()

    opts = [strategy: :one_for_one, name: Visilitator.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
