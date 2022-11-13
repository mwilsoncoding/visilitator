# Welcome to the Contribution Guide!

Pull requests are always welcome.

## Development setup

Development is focused around VSCode devcontainers, which run through a local `docker` daemon.

- [Download Docker](https://www.docker.com/products/docker-desktop/).
- [Download VSCode](https://code.visualstudio.com/download) and be sure it is [installed in your local `PATH`](https://code.visualstudio.com/docs/setup/mac#_launching-from-the-command-line).
- Start the `docker` daemon by starting Docker Desktop or manully invoking it via CLI.
- Clone this repository
- Navigate to the root of this repository
- Start VSCode
- When prompted, click the Reopen in Container button

### Perks

VSCode will bring up all service dependencies defined in the [compose file](.devcontainer/docker-compose.yaml) before attaching the terminal to a [container](.devcontainer/Dockerfile) suitable for developing this codebase.

The [devcontainer JSON definition](.devcontainer/devcontainer.json) will install `mix` and update local dependencies on startup.

The [gitignore](.gitignore) combined with the [compose file](.devcontainer/docker-compose.yaml)'s use of a cached workspace result in preservation of the local filesystem for useful directories not tracked in git (i.e. `_build`, `.mix`, `.hex`, `deps`, etc).

The devcontainer includes `psql` for convenience. The PostgreSQL serivce responds to the hostname, `pg`. Connection credentials can be found in the [dev environment configuration](https://www.docker.com/products/docker-desktop/).

### Usage

From a terminal in the VSCode devcontainer, run:
```console
iex -S mix
```

This starts an IEX session with the current code loaded.

Other commands common to development in Elixir can similarly be run from the VSCode devcontainer's terminal.

E.g.
```console
mix ecto.drop
mix ecto.create --quiet
mix ecto.migrate
mix format --check_formatted
mix test
mix credo
mix dialyzer
```