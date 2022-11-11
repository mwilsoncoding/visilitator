defmodule VisilitatorTest do
  use ExUnit.Case
  doctest Visilitator

  alias Visilitator.User

  test "creates user" do
    first_name = "little"
    last_name = "bobby"
    email = "tables"

    assert :ets.info(:users) |> Keyword.fetch!(:size) == 0
    assert Visilitator.create_account(first_name, last_name, email) == :ok
    assert :ets.info(:users) |> Keyword.fetch!(:size) == 1
  end

  test "requests a visit" do
    Visilitator.create_account("little", "bobby", "tables")

    member = :ets.lookup_element(:users, :ets.first(:users), 2)
    date = ~D[2021-01-01]
    minutes = 30
    tasks = ["talk", "laundry"]

    assert :ets.info(:visits) |> Keyword.fetch!(:size) == 0
    Visilitator.request_visit(member.id, date, minutes, tasks)
    assert :ets.info(:visits) |> Keyword.fetch!(:size) == 1

    debited_mins = member.balance - minutes
    assert User.lookup(member.id).balance == debited_mins
  end

  test "stops requests from members with a 0 balance of minutes" do
    Visilitator.create_account("little", "bobby", "tables")
    member = :ets.lookup_element(:users, :ets.first(:users), 2)

    assert :ets.info(:visits) |> Keyword.fetch!(:size) == 0
    Visilitator.request_visit(member.id, ~D[2021-01-01], 100, ["talk", "laundry"])

    assert :ets.info(:visits) |> Keyword.fetch!(:size) == 1

    assert catch_error(
             Visilitator.request_visit(member.id, ~D[2021-01-02], 1, ["talk", "laundry"])
           ) == :function_clause

    assert :ets.info(:visits) |> Keyword.fetch!(:size) == 1
  end

  test "stops members from requesting minutes beyond their balance" do
    Visilitator.create_account("little", "bobby", "tables")
    member = :ets.lookup_element(:users, :ets.first(:users), 2)

    assert :ets.info(:visits) |> Keyword.fetch!(:size) == 0

    assert catch_error(
             Visilitator.request_visit(member.id, ~D[2021-01-01], 101, ["talk", "laundry"])
           ) == :function_clause

    assert :ets.info(:visits) |> Keyword.fetch!(:size) == 0
  end

  test "fulfills a visit" do
    Visilitator.create_account("little", "bobby", "tables")
    Visilitator.create_account("first", "last", "email")

    member_key = :ets.first(:users)
    pal_key = :ets.next(:users, member_key)
    member = User.lookup(member_key)
    pal = User.lookup(pal_key)

    Visilitator.request_visit(member.id, ~D[2021-01-01], 30, ["talk", "laundry"])

    visit = :ets.lookup_element(:visits, :ets.first(:visits), 2)

    assert :ets.info(:transactions) |> Keyword.fetch!(:size) == 0
    Visilitator.fulfill_visit(pal.id, visit.id)
    assert :ets.info(:transactions) |> Keyword.fetch!(:size) == 1

    overhead_percent = Application.fetch_env!(:visilitator, Visilitator.User) |> Keyword.fetch!(:fulfillment_overhead_percentage)
    credited_mins = pal.balance + trunc(visit.minutes - (visit.minutes * overhead_percent))
    assert User.lookup(pal.id).balance == credited_mins
  end

  setup do
    on_exit(&clear_tables/0)
  end

  defp clear_tables() do
    :ets.delete_all_objects(:users)
    :ets.delete_all_objects(:visits)
    :ets.delete_all_objects(:transactions)
    assert :ets.info(:users) |> Keyword.fetch!(:size) == 0
    assert :ets.info(:visits) |> Keyword.fetch!(:size) == 0
    assert :ets.info(:transactions) |> Keyword.fetch!(:size) == 0
  end
end
