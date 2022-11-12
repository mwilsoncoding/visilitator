defmodule Visilitator.RepoCase do
  @moduledoc false
  use ExUnit.CaseTemplate

  using do
    quote do
      alias Visilitator.Repo

      import Ecto
      import Ecto.Query
      import Visilitator.RepoCase
    end
  end

  setup tags do
    :ok = Ecto.Adapters.SQL.Sandbox.checkout(Visilitator.Repo)

    unless tags[:async] do
      Ecto.Adapters.SQL.Sandbox.mode(Visilitator.Repo, {:shared, self()})
    end

    :ok
  end
end
