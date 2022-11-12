defmodule Visilitator.Repo.Migrations.CreateVisits do
  use Ecto.Migration

  def change do
    create table(:visits) do
      add :member, :id
      add :date, :date
      add :minutes, :integer
      add :tasks, {:array, :string}
    end
  end
end
