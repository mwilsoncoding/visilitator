defmodule Visilitator.User do
  @moduledoc """
  User object
  """
  use Ecto.Schema

  alias Visilitator.Repo
  alias Visilitator.Visit

  @type t :: %__MODULE__{}

  schema "users" do
    field(:first_name, :string)
    field(:last_name, :string)
    field(:email, :string)
    field(:balance, :integer)
  end

  defp balance_changeset(user = %__MODULE__{}, params = %{}) do
    user
    |> Ecto.Changeset.cast(params, [:balance])
    |> Ecto.Changeset.validate_required([:balance])
  end

  @doc """
  Given first_name, last_name, and email, this function creates, persists to storage, and returns a User
  """
  @spec create(binary, binary, binary) :: t()
  def create(first_name, last_name, email)
      when is_binary(first_name) and is_binary(last_name) and is_binary(email) do
    %__MODULE__{
      first_name: first_name,
      last_name: last_name,
      email: email,
      balance: 100
    }
    |> Repo.insert!()
  end

  @doc """
  Given user and minutes, this function updates storage for the User with the difference of the user's balance and the given minutes
  """
  @spec debit(t(), Visit.t()) :: Ecto.Changeset.t()
  def debit(user = %__MODULE__{}, visit = %Visit{})
      when user.balance > 0 and user.balance >= visit.minutes do
    balance_changeset(user, %{balance: total_after_debit(user, visit)})
  end

  @doc """
  Given user and minutes, this function updates storage for the User with the sum of the user's balance and 85% of the given minutes
  """
  @spec fulfill(t(), Visit.t()) :: Ecto.Changeset.t()
  def fulfill(user = %__MODULE__{}, visit = %Visit{}) do
    balance_changeset(user, %{
      balance: total_after_fulfillment(user, visit)
    })
  end

  @doc """

  """
  @spec total_after_debit(t(), Visit.t()) :: non_neg_integer()
  def total_after_debit(user = %__MODULE__{}, visit = %Visit{}) do
    user.balance - visit.minutes
  end

  @doc """

  """
  @spec total_after_fulfillment(t(), Visit.t()) :: pos_integer()
  def total_after_fulfillment(user = %__MODULE__{}, visit = %Visit{}) do
    overhead_percent =
      Application.fetch_env!(:visilitator, __MODULE__)
      |> Keyword.fetch!(:fulfillment_overhead_percentage)

    user.balance + trunc(visit.minutes - visit.minutes * overhead_percent)
  end
end
