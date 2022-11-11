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
  @spec create_account(String.t(), String.t(), String.t()) :: :ok
  def create_account(first_name, last_name, email) do
    user = User.create(first_name, last_name, email)

    # IO is currently the UI. This makes testing noisy, but should be fine for a PoC/MVP.
    IO.puts("Your user ID is: #{user.id}")
  end

  @doc """
  Request Visit
  """
  @spec request_visit(String.t(), String.t(), pos_integer(), list(String.t())) :: :ok
  def request_visit(user_id, date, minutes, tasks) do
    User.lookup(user_id)
    |> User.debit(minutes)

    visit = Visit.create(user_id, date, minutes, tasks)
    IO.puts("Your visit ID is: #{visit.id}")
  end

  @doc """
  Fulfill Visit
  """
  @spec fulfill_visit(String.t(), String.t()) :: :ok
  def fulfill_visit(user_id, visit_id) do
    pal = User.lookup(user_id)
    visit = Visit.lookup(visit_id)

    # In a DB impl, the following updates would happen in a single transaction
    User.fulfill(pal, visit.minutes)
    txn = Transaction.create(visit.member_id, pal.id, visit.id)
    IO.puts("Your transaction ID is: #{txn.id}")
  end
end
