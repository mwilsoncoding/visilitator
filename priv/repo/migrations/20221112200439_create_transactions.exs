defmodule Visilitator.Repo.Migrations.CreateTransactions do
  use Ecto.Migration

  def change do
    create table(:transactions) do
      add :member, :id
      add :pal, :id
      add :visit, :id
    end
  end
end
