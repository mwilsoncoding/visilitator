defmodule Visilitator.User do
  @moduledoc """
  User object
  """

  @type t :: %__MODULE__{
          id: String.t(),
          first_name: String.t(),
          last_name: String.t(),
          email: String.t(),
          balance: non_neg_integer()
        }
  defstruct [:id, :first_name, :last_name, :email, :balance]

  @doc """
  Given first_name, last_name, and email, this function creates, persists to storage, and returns a User
  """
  @spec create(String.t(), String.t(), String.t()) :: t()
  def create(first_name, last_name, email) do
    uid = UUID.uuid4()

    user = %__MODULE__{
      id: uid,
      first_name: first_name,
      last_name: last_name,
      email: email,
      balance: 100
    }

    :ets.insert_new(:users, {uid, user})
    user
  end

  @doc """
  Given user_id, this function returns the matching User from storage
  """
  @spec lookup(String.t()) :: t()
  def lookup(user_id), do: :ets.lookup_element(:users, user_id, 2)

  @doc """
  Given user and minutes, this function updates storage for the User with the difference of the user's balance and the given minutes
  """
  @spec debit(t(), pos_integer()) :: true
  def debit(user = %__MODULE__{}, minutes) when user.balance > 0 and user.balance >= minutes do
    :ets.insert(:users, {user.id, %{user | balance: user.balance - minutes}})
  end

  @doc """
  Given user and minutes, this function updates storage for the User with the sum of the user's balance and 85% of the given minutes
  """
  @spec fulfill(t(), pos_integer()) :: true
  def fulfill(user = %__MODULE__{}, minutes) do
    overhead_percent =
      Application.fetch_env!(:visilitator, __MODULE__)
      |> Keyword.fetch!(:fulfillment_overhead_percentage)

    :ets.insert(
      :users,
      {user.id, %{user | balance: user.balance + trunc(minutes - minutes * overhead_percent)}}
    )
  end
end
