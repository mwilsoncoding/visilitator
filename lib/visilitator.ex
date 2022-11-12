defmodule Visilitator do
  @moduledoc """
  Visit Facilitator

  The Visilitator is a system that allows for User creation and
  interaction through a request/fulfillment process around Visits.
  """

  alias Visilitator.User
  alias Visilitator.Visit
  alias Visilitator.Transaction

  @doc """
  Create Account
  """
  @spec create_account(String.t(), String.t(), String.t()) :: User.t()
  def create_account(first_name, last_name, email)
      when is_binary(first_name) and is_binary(last_name) and is_binary(email) do
    User.create(first_name, last_name, email)
  end

  @doc """
  Request Visit
  """
  @spec request_visit(User.t(), Date.t(), pos_integer(), list(String.t())) :: Visit.t()
  def request_visit(user, date, minutes, tasks)
      when user.balance > 0 and minutes <= user.balance do
    user
    |> Visit.create(date, minutes, tasks)
  end

  @doc """
  Fulfill Visit
  """
  @spec fulfill_visit(User.t(), Visit.t()) :: {Transaction.t(), User.t(), User.t()}
  def fulfill_visit(user, visit) do
    Transaction.create(user, visit)
  end
end
