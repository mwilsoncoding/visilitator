defmodule Visilitator.UserTest do
  use Visilitator.RepoCase
  alias Visilitator.User
  doctest User

  test "creates" do
    first_name = "little"
    last_name = "bobby"
    email = "tables"

    %User{id: _, first_name: _, last_name: _, email: _, balance: 100} =
      User.create(first_name, last_name, email)

    assert User |> Repo.all() |> Enum.count() == 1
  end

  test "debits" do
    member = User.create("little", "bobby", "tables")
    visit = Visilitator.request_visit(member, ~D[2021-01-01], 50, ["foo", "bar"])

    member |> User.debit(visit)

    assert (User |> Repo.get(member.id)).balance == 50
  end

  test "fulfills" do
    member = User.create("little", "bobby", "tables")

    visit = Visilitator.request_visit(member, ~D[2021-01-01], 50, ["foo", "bar"])

    pal =
      User.create("port", "monteau", "wordplay@gmail.com")
      |> User.fulfill(visit)

    assert (User |> Repo.get(pal.id)).balance == 142
  end
end
