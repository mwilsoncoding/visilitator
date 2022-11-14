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

  @doc """
  Given a user and parameters to potentially update, this function returns
  an Ecto Changeset suitable for modifying the balance of a user
  """
  @spec balance_changeset(t(), map()) :: Ecto.Changeset.t()
  def balance_changeset(user = %__MODULE__{}, params = %{}) do
    user
    |> Ecto.Changeset.cast(params, [:balance])
    |> Ecto.Changeset.validate_required([:balance])
  end

  @doc """
  Given first_name, last_name, and email, this function creates, persists to
  storage, and returns a User
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
end
