# Visilitator

The Visit Facilitator!

## Running

From the prompt:
> This application may be command-line or API-only. It does not require a graphical or web interface.

### VSCode

VSCode setup and usage instructions are included in the [Contribution Guide](CONTRIBUTING.md)

### Docker

If you have `docker` installed, the quickest way to test/interact with this code is to run one of the images published to the GitHub Container Registry:

- Start a postgres DB
```console
docker run --rm \
  --name pg \
  -e POSTGRES_PASSWORD=pg \
  -d \
  postgres:15-alpine
```
- Run tests (using the `test` image)
```console
docker run --rm \
  -it \
  -e DB_HOST=$(docker inspect -f "{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}" pg) \
  -e DB_PASSWORD=pg \
  -e ENABLE_BROADWAY=false \
  ghcr.io/mwilsoncoding/visilitator/visilitator-builder:test-1.14.1-7d4d216deca53f481a8a168110a31110ae541320 mix test
```
- Run code in `iex` (using the `prod` image)
```console
docker run --rm \
  -it \
  -e DB_HOST=$(docker inspect -f "{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}" pg) \
  -e DB_PASSWORD=pg \
  -e ENABLE_BROADWAY=false \
  ghcr.io/mwilsoncoding/visilitator/visilitator-builder:prod-1.14.1-7d4d216deca53f481a8a168110a31110ae541320 iex -S mix
```
  - E.g.
  ```elixir
  Erlang/OTP 25 [erts-13.1.2] [source] [64-bit] [smp:8:8] [ds:8:8:10] [async-threads:1] [jit]

  Generated visilitator app
  Interactive Elixir (1.14.1) - press Ctrl+C to exit (type h() ENTER for help)
  iex(1)> Visilitator.create_account("little", "bobby", "tables")
  %Visilitator.User{
    __meta__: #Ecto.Schema.Metadata<:loaded, "users">,
    id: 34,
    first_name: "little",
    last_name: "bobby",
    email: "tables",
    balance: 100
  }
  iex(2)> v(1) |> Visilitator.request_visit(Date.utc_today(), 30, ["talk", "laundry"])
  %Visilitator.Visit{
    __meta__: #Ecto.Schema.Metadata<:loaded, "visits">,
    id: 34,
    member: 34,
    date: ~D[2022-11-13],
    minutes: 30,
    tasks: ["talk", "laundry"]
  }
  iex(3)> Visilitator.create_account("port", "monteau", "wordplay@gmail.com")
  %Visilitator.User{
    __meta__: #Ecto.Schema.Metadata<:loaded, "users">,
    id: 35,
    first_name: "port",
    last_name: "monteau",
    email: "wordplay@gmail.com",
    balance: 100
  }
  iex(4)> v(3) |> Visilitator.fulfill_visit(v(2))
  {%Visilitator.Transaction{
     __meta__: #Ecto.Schema.Metadata<:loaded, "transactions">,
     id: 34,
     member: 34,
     pal: 35,
     visit: 34
   },
   %Visilitator.User{
     __meta__: #Ecto.Schema.Metadata<:loaded, "users">,
     id: 34,
     first_name: "little",
     last_name: "bobby",
     email: "tables",
     balance: 70
   },
   %Visilitator.User{
     __meta__: #Ecto.Schema.Metadata<:loaded, "users">,
     id: 35,
     first_name: "port",
     last_name: "monteau",
     email: "wordplay@gmail.com",
     balance: 125
   }}
  ```
