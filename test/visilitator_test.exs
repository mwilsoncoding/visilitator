defmodule VisilitatorTest do
  use Visilitator.RepoCase, async: true
  doctest Visilitator

  alias Visilitator.User
  alias Visilitator.Visit
  alias Visilitator.Transaction
  alias Visilitator.Broadway.CreateAccount
  alias Visilitator.Broadway.RequestVisit
  alias Visilitator.Broadway.FulfillVisit

  test "creates an account" do
    broadway_name = new_unique_name()

    Broadway.start_link(CreateAccount,
      name: broadway_name,
      producer: [
        module: {Broadway.DummyProducer, []}
      ],
      processors: [
        default: [
          concurrency: 1
        ]
      ]
    )

    assert User |> Repo.all() |> Enum.count() == 0

    payload = %{"first_name" => "little", "last_name" => "bobby", "email" => "tables"}

    ref =
      Broadway.test_message(
        broadway_name,
        JSON.encode!(payload),
        metadata: %{ecto_sandbox: self()}
      )

    assert_receive {:ack, ^ref, [%{data: data}], []}, 1000

    assert JSON.decode!(data) == payload

    assert User |> Repo.all() |> Enum.count() == 1
  end

  test "requests a visit" do
    broadway_name = new_unique_name()

    Broadway.start_link(RequestVisit,
      name: broadway_name,
      producer: [
        module: {Broadway.DummyProducer, []}
      ],
      processors: [
        default: [
          concurrency: 1
        ]
      ]
    )

    member = Visilitator.create_account("little", "bobby", "tables")

    assert Visit |> Repo.all() |> Enum.count() == 0

    payload = %{
      "member" => "#{member.id}",
      "date" => "#{~D[2021-01-01]}",
      "minutes" => 30,
      "tasks" => ["talk", "laundry"]
    }

    ref =
      Broadway.test_message(
        broadway_name,
        JSON.encode!(payload),
        metadata: %{ecto_sandbox: self()}
      )

    assert_receive {:ack, ^ref, [%{data: data}], []}, 1000

    assert JSON.decode!(data) == payload

    assert Visit |> Repo.all() |> Enum.count() == 1
  end

  test "stops members from requesting minutes beyond their balance" do
    broadway_name = new_unique_name()

    Broadway.start_link(RequestVisit,
      name: broadway_name,
      producer: [
        module: {Broadway.DummyProducer, []}
      ],
      processors: [
        default: [
          concurrency: 1
        ]
      ]
    )

    member = Visilitator.create_account("little", "bobby", "tables")

    assert Visit |> Repo.all() |> Enum.count() == 0

    payload = %{
      "member" => "#{member.id}",
      "date" => "#{~D[2021-01-01]}",
      "minutes" => 101,
      "tasks" => ["talk", "laundry"]
    }

    ref =
      Broadway.test_message(
        broadway_name,
        JSON.encode!(payload),
        metadata: %{ecto_sandbox: self()}
      )

    assert_receive {:ack, ^ref, [],
                    [
                      %{
                        data: data,
                        status:
                          {:error,
                           %FunctionClauseError{
                             module: Visilitator,
                             function: :request_visit,
                             arity: 4,
                             kind: nil,
                             args: nil,
                             clauses: nil
                           }, _}
                      }
                    ]},
                   1000

    assert JSON.decode!(data) == payload

    assert Visit |> Repo.all() |> Enum.count() == 0
  end

  test "fulfills a visit" do
    broadway_name = new_unique_name()

    Broadway.start_link(FulfillVisit,
      name: broadway_name,
      producer: [
        module: {Broadway.DummyProducer, []}
      ],
      processors: [
        default: [
          concurrency: 1
        ]
      ]
    )

    member = Visilitator.create_account("little", "bobby", "tables")
    pal = Visilitator.create_account("first", "last", "email")
    visit = Visilitator.request_visit(member, ~D[2021-01-01], 30, ["talk", "laundry"])

    assert Transaction |> Repo.all() |> Enum.count() == 0

    payload = %{"pal" => "#{pal.id}", "visit" => "#{visit.id}"}

    ref =
      Broadway.test_message(
        broadway_name,
        JSON.encode!(payload),
        metadata: %{ecto_sandbox: self()}
      )

    assert_receive {:ack, ^ref, [%{data: data}], []}, 1000

    assert JSON.decode!(data) == payload

    assert Transaction |> Repo.all() |> Enum.count() == 1

    debited_mins = member.balance - visit.minutes
    assert (User |> Repo.get(member.id)).balance == debited_mins

    overhead_percent =
      Application.fetch_env!(:visilitator, Visilitator.User)
      |> Keyword.fetch!(:fulfillment_overhead_percentage)

    credited_mins = pal.balance + trunc(visit.minutes - visit.minutes * overhead_percent)
    assert (User |> Repo.get(pal.id)).balance == credited_mins
  end

  test "stops requests from members with a 0 balance of minutes" do
    broadway_name = new_unique_name()

    Broadway.start_link(RequestVisit,
      name: broadway_name,
      producer: [
        module: {Broadway.DummyProducer, []}
      ],
      processors: [
        default: [
          concurrency: 1
        ]
      ]
    )

    member = Visilitator.create_account("little", "bobby", "tables")
    pal = Visilitator.create_account("port", "monteau", "wordplay@gmail.com")
    visit = Visilitator.request_visit(member, ~D[2021-01-01], 100, ["talk", "laundry"])
    {_, member, _} = Visilitator.fulfill_visit(pal, visit)
    member = User |> Repo.get(member.id)

    payload = %{
      "member" => "#{member.id}",
      "date" => "#{~D[2021-01-01]}",
      "minutes" => 1,
      "tasks" => ["clean"]
    }

    ref =
      Broadway.test_message(
        broadway_name,
        JSON.encode!(payload),
        metadata: %{ecto_sandbox: self()}
      )

    assert_receive {:ack, ^ref, [],
                    [
                      %{
                        data: data,
                        status:
                          {:error,
                           %FunctionClauseError{
                             module: Visilitator,
                             function: :request_visit,
                             arity: 4,
                             kind: nil,
                             args: nil,
                             clauses: nil
                           }, _}
                      }
                    ]},
                   1000

    assert JSON.decode!(data) == payload

    assert Visit |> Repo.all() |> Enum.count() == 1
  end

  defp new_unique_name() do
    :"Elixir.Broadway#{System.unique_integer([:positive, :monotonic])}"
  end
end
