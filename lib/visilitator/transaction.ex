defmodule Visilitator.Transaction do
  @moduledoc """
  Transaction object
  """

  alias Visilitator.Repo
  alias Visilitator.User
  alias Visilitator.Visit

  @type t :: %__MODULE__{
          id: String.t(),
          member_id: integer(),
          pal_id: integer(),
          visit_id: String.t()
        }
  defstruct [:id, :member_id, :pal_id, :visit_id]

  @doc """
  Given member_id, pal_id, and visit_id, this function creates, persists to storage, and returns a Transaction
  """
  @spec create(User.t(), Visit.t()) :: {t(), User.t(), User.t()}
  def create(pal = %User{}, visit = %Visit{}) do
    # Good place for an ecto multi
    User
    |> Repo.get(visit.member)
    |> User.debit(visit)

    pal
    |> User.fulfill(visit)

    tid = UUID.uuid4()
    txn = %__MODULE__{id: tid, member_id: visit.member, pal_id: pal.id, visit_id: visit.id}
    :ets.insert(:transactions, {tid, txn})
    {txn, User |> Repo.get(visit.member), User |> Repo.get(pal.id)}
  end
end
