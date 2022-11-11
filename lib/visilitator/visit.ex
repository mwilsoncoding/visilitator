defmodule Visilitator.Visit do
  @moduledoc """
  Visit object
  """

  @type t :: %__MODULE__{
          id: String.t(),
          member_id: String.t(),
          date: String.t(),
          minutes: non_neg_integer(),
          tasks: list(String.t())
        }
  defstruct [:id, :member_id, :date, :minutes, :tasks]

  @doc """
  Given user_id, date, minutes, and tasks, this function creates, persists to storage, and returns a Visit
  """
  @spec create(String.t(), String.t(), non_neg_integer(), list(String.t())) :: t()
  def create(user_id, date, minutes, tasks) do
    vid = UUID.uuid4()
    visit = %__MODULE__{id: vid, member_id: user_id, date: date, minutes: minutes, tasks: tasks}
    :ets.insert(:visits, {vid, visit})
    visit
  end

  @doc """
  Given visit_id, this function returns the matching Visit from storage
  """
  @spec lookup(String.t()) :: t()
  def lookup(visit_id), do: :ets.lookup_element(:visits, visit_id, 2)
end
