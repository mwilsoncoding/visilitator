defmodule Visilitator.Release do
  @moduledoc """
  Production environment lacks `mix`. This Module provides facilities to get around that.
  """

  alias Visilitator.Repo
  alias Ecto.Migrator

  @app :visilitator

  # Function for populating the database.
  # This runs `priv/repo/seeds.exs`
  def seed do
    load_app()

    {:ok, _, _} = Migrator.with_repo(Repo, &run_seeds/1)
  end

  defp run_seeds(_) do
    Code.eval_file(seeds_file())
  end

  def migrate do
    load_app()

    for repo <- repos() do
      {:ok, _, _} = Migrator.with_repo(repo, &Migrator.run(&1, :up, all: true))
    end
  end

  def rollback(repo, version) do
    load_app()
    {:ok, _, _} = Migrator.with_repo(repo, &Migrator.run(&1, :down, to: version))
  end

  defp seeds_file do
    Application.fetch_env!(@app, :seeds_file)
  end

  defp repos do
    Application.fetch_env!(@app, :ecto_repos)
  end

  defp load_app do
    Application.load(@app)
  end
end
