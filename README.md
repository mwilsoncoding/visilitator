# Visilitator

The Visit Facilitator!

## Running

From the prompt:
> This application may be command-line or API-only. It does not require a graphical or web interface.

### VSCode

VSCode setup and usage instructions are included in the [Contribution Guide](CONTRIBUTING.md)

### Kubernetes

This repo includes a [helm chart](helm/visilitator/Chart.yaml).

It has been tested using the local kubernetes cluster feature of Docker Desktop.

Requires Docker Desktop, kubectl, and helm. Optionally psql for db inspection.

With Docker Desktop running and the k8s engine running:
```console
git clone https://github.com/mwilsoncoding/visilitator.git
cd visilitator
unset KUBECONFIG
# Create a secret in the cluster (the chart doesn't provide one).
# This is for demo purposes only.
# A proper secrets management like SOPS or SealedSecrets is encouraged.
cat <<EOF > not-so-secret.yaml
apiVersion: v1
kind: Secret
metadata:
  name: visilitator
  namespace: visilitator
stringData:
  db-password: pg
  rabbitmq-password: rmq
  postgres-password: pg
  password: pg
  RABBITMQ_PASSWORD: rmq
EOF
kubectl create ns visilitator
kubectl apply -f not-so-secret.yaml
helm install visilitator . -n visilitator
```

Once installed, port-forward RabbitMQ's management portal:
```console
kubectl port-forward svc/visilitator-rabbitmq -n visilitator 15672:15672
```

Navigate to [`localhost:15672/#/queues/%2F/create_account`](localhost:15672/#/queues/%2F/create_account) and log into the management portal using your configured password. The user name is `user` by default.

Click the `Publish message` dropdown to access a form.

Enter the desired Payload and click the `Publish message` button to submit the form.

Here is an example of a valid JSON message for the `create_account` queue:
```json
{"first_name": "little", "last_name": "bobby", "email": "tables"}
```

The system doesn't have much of a UI, but logs can be inspected:
```console
kubectl logs -l app.kubernetes.io/name=visilitator -n visilitator -c visilitator
```

Postgres can also be queried by port-forwarding its headless service:
```console
kubectl port-forward svc/visilitator-postgresql-hl -n visilitator 5432:5432
```

Followed by connecting from a local psql client from another terminal:
```console
psql -h 127.0.0.1 -U visilitator
```

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
  -e LOG_LEVEL=none \
  ghcr.io/mwilsoncoding/visilitator/visilitator-builder:test-1.14.1-3bcc18149b87aec9bff8a644b004c04b9f7408e1 mix test
```
- Run code in `iex` (using the `prod` image)
```console
docker run --rm \
  -it \
  -e DB_HOST=$(docker inspect -f "{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}" pg) \
  -e DB_PASSWORD=pg \
  -e ENABLE_BROADWAY=false \
  ghcr.io/mwilsoncoding/visilitator/visilitator-builder:prod-1.14.1-3bcc18149b87aec9bff8a644b004c04b9f7408e1 iex -S mix
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
