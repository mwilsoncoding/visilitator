defmodule Visilitator.Transaction do
  @moduledoc """
  Transaction object
  """

  @type t :: %__MODULE__{
          id: String.t(),
          member_id: String.t(),
          pal_id: String.t(),
          visit_id: String.t()
        }
  defstruct [:id, :member_id, :pal_id, :visit_id]

  @doc """
  Given member_id, pal_id, and visit_id, this function creates, persists to storage, and returns a Transaction
  """
  @spec create(String.t(), String.t(), String.t()) :: t()
  def create(member_id, pal_id, visit_id) do
    tid = UUID.uuid4()
    txn = %__MODULE__{id: tid, member_id: member_id, pal_id: pal_id, visit_id: visit_id}
    :ets.insert(:transactions, {tid, txn})
    txn
  end
end
