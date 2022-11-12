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
end
