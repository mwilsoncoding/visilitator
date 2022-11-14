defmodule Visilitator.Transaction do
  @moduledoc """
  Transaction object
  """
  use Ecto.Schema

  alias Visilitator.Repo
  alias Visilitator.User
  alias Visilitator.Visit

  @type t :: %__MODULE__{}

  schema "transactions" do
    field(:member, :integer)
    field(:pal, :integer)
    field(:visit, :integer)
  end

  @doc """
  Given a pal and a visit, this function creates a Transaction and persists to storage while
  updating the given pal and the member associated with the given visit.
  """
  @spec create(User.t(), Visit.t()) :: {t(), User.t(), User.t()}
  def create(pal = %User{}, visit = %Visit{}) do
    member = User |> Repo.get(visit.member)
    debited_amount = member |> total_after_debit(visit)
    fulfilled_amount = pal |> total_after_fulfillment(visit)

    transaction = %__MODULE__{
      member: visit.member,
      pal: pal.id,
      visit: visit.id
    }

    {:ok, changes} =
      Ecto.Multi.new()
      |> Ecto.Multi.update(
        :debit_member,
        User.balance_changeset(member, %{balance: total_after_debit(member, visit)})
      )
      |> Ecto.Multi.run(:check_debit, fn
        _repo, %{debit_member: %User{balance: ^debited_amount}} -> {:ok, nil}
        _repo, %{debit_member: _} -> {:error, {:failed_debit, member}}
      end)
      |> Ecto.Multi.update(
        :fulfill_pal,
        User.balance_changeset(pal, %{balance: total_after_fulfillment(pal, visit)})
      )
      |> Ecto.Multi.run(:check_fulfill, fn
        _repo, %{fulfill_pal: %User{balance: ^fulfilled_amount}} -> {:ok, nil}
        _repo, %{fulfill_pal: _} -> {:error, {:failed_fulfill, pal}}
      end)
      |> Ecto.Multi.insert(:create_transaction, transaction)
      |> Repo.transaction()

    {changes.create_transaction, changes.debit_member, changes.fulfill_pal}
  end

  defp total_after_debit(user = %User{}, visit = %Visit{}) do
    user.balance - visit.minutes
  end

  defp total_after_fulfillment(user = %User{}, visit = %Visit{}) do
    overhead_percent =
      Application.fetch_env!(:visilitator, __MODULE__)
      |> Keyword.fetch!(:fulfillment_overhead_percentage)

    user.balance + trunc(visit.minutes - visit.minutes * overhead_percent)
  end
end
