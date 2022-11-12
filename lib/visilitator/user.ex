defmodule Visilitator.User do
  @moduledoc """
  User object
  """
  use Ecto.Schema

  alias Visilitator.Repo

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
  Given user_id, this function returns the matching User from storage
  """
  @spec lookup(integer()) :: t()
  def lookup(user_id) when is_integer(user_id), do: __MODULE__ |> Repo.get(user_id)

  @doc """
  Given user and minutes, this function updates storage for the User with the difference of the user's balance and the given minutes
  """
  @spec debit(t(), pos_integer()) :: t()
  def debit(user = %__MODULE__{}, minutes)
      when is_integer(minutes) and minutes > 0 and user.balance > 0 and user.balance >= minutes do
    balance_changeset(user, %{balance: user.balance - minutes})
    |> Repo.update!()
  end

  @doc """
  Given user and minutes, this function updates storage for the User with the sum of the user's balance and 85% of the given minutes
  """
  @spec fulfill(t(), pos_integer()) :: t()
  def fulfill(user = %__MODULE__{}, minutes) when is_integer(minutes) and minutes > 0 do
    overhead_percent =
      Application.fetch_env!(:visilitator, __MODULE__)
      |> Keyword.fetch!(:fulfillment_overhead_percentage)

    balance_changeset(user, %{balance: user.balance + trunc(minutes - minutes * overhead_percent)})
    |> Repo.update!()
  end
end
