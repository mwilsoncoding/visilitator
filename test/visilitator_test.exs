defmodule VisilitatorTest do
  use Visilitator.RepoCase
  doctest Visilitator

  alias Visilitator.User
  alias Visilitator.Visit

  test "persists user on creation" do
    first_name = "little"
    last_name = "bobby"
    email = "tables"

    assert User |> Repo.all() |> Enum.count() == 0

    %User{id: _, first_name: ^first_name, last_name: ^last_name, email: ^email, balance: 100} =
      Visilitator.create_account(first_name, last_name, email)

    assert User |> Repo.all() |> Enum.count() == 1
  end

  test "requests a visit" do
    member = Visilitator.create_account("little", "bobby", "tables")

    date = ~D[2021-01-01]
    minutes = 30
    tasks = ["talk", "laundry"]

    id = member.id

    %Visit{member: ^id, minutes: 30, date: ^date, tasks: ^tasks} =
      Visilitator.request_visit(member, date, minutes, tasks)

    assert Visit |> Repo.all() |> Enum.count() == 1
  end

  test "stops members from requesting minutes beyond their balance" do
    Visilitator.create_account("little", "bobby", "tables")
    [member | []] = User |> Repo.all()

    assert Visit |> Repo.all() |> Enum.count() == 0

    assert catch_error(
             Visilitator.request_visit(member, ~D[2021-01-01], 101, ["talk", "laundry"])
           ) == :function_clause

    assert Visit |> Repo.all() |> Enum.count() == 0
  end

  test "fulfills a visit" do
    member = Visilitator.create_account("little", "bobby", "tables")
    pal = Visilitator.create_account("first", "last", "email")
    visit = Visilitator.request_visit(member, ~D[2021-01-01], 30, ["talk", "laundry"])

    assert :ets.info(:transactions) |> Keyword.fetch!(:size) == 0
    Visilitator.fulfill_visit(pal, visit)
    assert :ets.info(:transactions) |> Keyword.fetch!(:size) == 1

    debited_mins = member.balance - visit.minutes
    assert (User |> Repo.get(member.id)).balance == debited_mins

    overhead_percent =
      Application.fetch_env!(:visilitator, Visilitator.User)
      |> Keyword.fetch!(:fulfillment_overhead_percentage)

    credited_mins = pal.balance + trunc(visit.minutes - visit.minutes * overhead_percent)
    assert (User |> Repo.get(pal.id)).balance == credited_mins
  end

  test "stops requests from members with a 0 balance of minutes" do
    member = Visilitator.create_account("little", "bobby", "tables")
    pal = Visilitator.create_account("port", "monteau", "wordplay@gmail.com")
    visit = Visilitator.request_visit(member, ~D[2021-01-01], 100, ["talk", "laundry"])
    {_, member, _} = Visilitator.fulfill_visit(pal, visit)
    member = User |> Repo.get(member.id)

    assert catch_error(Visilitator.request_visit(member, ~D[2021-01-02], 1, ["talk", "laundry"])) ==
             :function_clause

    assert Visit |> Repo.all() |> Enum.count() == 1
  end

  setup do
    on_exit(&clear_tables/0)
  end

  defp clear_tables() do
    :ets.delete_all_objects(:transactions)
    assert :ets.info(:transactions) |> Keyword.fetch!(:size) == 0
  end
end
