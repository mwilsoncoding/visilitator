defmodule Visilitator.Broadway.RequestVisit do
  @moduledoc false
  use Broadway

  alias Visilitator.User
  alias Visilitator.Repo

  @spec start_link(any) :: :ignore | {:error, any} | {:ok, pid}
  def start_link(_opts) do
    Broadway.start_link(__MODULE__,
      name: RequestVisit,
      producer: [
        module:
          {Application.fetch_env!(:visilitator, :rabbitmq) |> Keyword.fetch!(:producer),
           on_failure: :reject,
           queue: Application.fetch_env!(:visilitator, __MODULE__) |> Keyword.fetch!(:queue),
           declare: [durable: true],
           connection: [
             host: Application.fetch_env!(:visilitator, :rabbitmq) |> Keyword.fetch!(:host),
             username:
               Application.fetch_env!(:visilitator, :rabbitmq) |> Keyword.fetch!(:username),
             password:
               Application.fetch_env!(:visilitator, :rabbitmq) |> Keyword.fetch!(:password)
           ],
           qos: [
             prefetch_count: 50
           ]},
        concurrency: 1
      ],
      processors: [
        default: [
          concurrency: 50
        ]
      ]
    )
  end

  @doc """
  Async message ingestion for request_visit.

  Example JSON message:
    {"member": 18, "date": "2023-02-02", "minutes": 22, "tasks": ["cook", "clean"]}
  """
  @impl true
  def handle_message(_, message, _) do
    %{"member" => member, "date" => date, "minutes" => minutes, "tasks" => tasks} =
      message.data |> JSON.decode!()

    date = Date.from_iso8601!(date)

    User
    |> Repo.get(member)
    |> Visilitator.request_visit(date, minutes, tasks)

    message
  end
end
