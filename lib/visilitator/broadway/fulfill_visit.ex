defmodule Visilitator.Broadway.FulfillVisit do
  @moduledoc false
  use Broadway

  alias Visilitator.User
  alias Visilitator.Visit
  alias Visilitator.Repo

  @spec start_link(any) :: :ignore | {:error, any} | {:ok, pid}
  def start_link(_opts) do
    Broadway.start_link(__MODULE__,
      name: FulfillVisit,
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

  @impl true
  def handle_message(_, message, _) do
    %{"pal" => pal, "visit" => visit} = message.data |> JSON.decode!()

    visit =
      Visit
      |> Repo.get(visit)

    User
    |> Repo.get(pal)
    |> Visilitator.fulfill_visit(visit)

    message
  end
end
