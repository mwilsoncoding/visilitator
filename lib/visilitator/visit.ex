defmodule Visilitator.Visit do
  @moduledoc """
  Visit object
  """
  use Ecto.Schema

  alias Visilitator.Repo
  alias Visilitator.User

  @type t :: %__MODULE__{}

  schema "visits" do
    field(:member, :integer)
    field(:date, :date)
    field(:minutes, :integer)
    field(:tasks, {:array, :string})
  end

  @doc """
  Given a user, date, minutes, and list of tasks, this function creates, persists to storage, and returns a Visit
  """
  @spec create(User.t(), Date.t(), non_neg_integer(), list(String.t())) :: t()
  def create(user, date, minutes, tasks) when is_integer(minutes) and minutes > 0 do
    %__MODULE__{
      member: user.id,
      date: date,
      minutes: minutes,
      tasks: tasks
    }
    |> Repo.insert!()
  end
end
