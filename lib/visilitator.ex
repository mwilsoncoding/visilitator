defmodule Visilitator do
  @moduledoc """
  Visit Facilitator

  The Visilitator is a system that allows for User creation and
  interaction through a request/fulfillment process around Visits.
  """
  require Logger

  alias Visilitator.User
  alias Visilitator.Visit
  alias Visilitator.Transaction

  @doc """
  Create Account
  """
  @spec create_account(String.t(), String.t(), String.t()) :: User.t()
  def create_account(first_name, last_name, email)
      when is_binary(first_name) and is_binary(last_name) and is_binary(email) do
    user = User.create(first_name, last_name, email)
    Logger.info("Created user with id: #{user.id}")
    user
  end

  @doc """
  Request Visit
  """
  @spec request_visit(User.t(), Date.t(), pos_integer(), list(String.t())) :: Visit.t()
  def request_visit(member, date, minutes, tasks)
      when member.balance > 0 and minutes <= member.balance do
    visit =
      member
      |> Visit.create(date, minutes, tasks)

    Logger.info("Created visit with id: #{visit.id}")
    visit
  end

  @doc """
  Fulfill Visit
  """
  @spec fulfill_visit(User.t(), Visit.t()) :: {Transaction.t(), User.t(), User.t()}
  def fulfill_visit(pal, visit) do
    {txn, member, pal} = Transaction.create(pal, visit)
    Logger.info("Created transaction with id: #{txn.id}")
    {txn, member, pal}
  end
end
