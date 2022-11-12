# Visilitator

The Visit Facilitator!

## Running

From the prompt:
> This application may be command-line or API-only. It does not require a graphical or web interface.

Steps for running and interacting with this repository (copy/paste-able):

- Clone the repository
```console
git clone 
```
- Navigate to the root of the repository
```console
cd visilitator
```
- Build an OCI image with the `--target` set to `builder` to compile the code with access to `mix` and `iex`
```console
docker build -t visilitator-builder --target builder .
```
- Run tests
```console
docker run --rm -it visilitator-builder mix test
```
- Run code in `iex`
```console
docker run --rm -it visilitator-builder iex -S mix
```
- In `iex`:
  - create an account
    ```elixir
    Visilitator.create_account("bobby", "tables", "bobby.tables@gmail.com")
    ```
  - request a visit using the user ID obtained from creating an account
    ```elixir
    Visilitator.request_visit(1, "01-01-2023", 30, ["talk", "laundry"])
    ```
  - create a pal user
    ```elixir
    Visilitator.create_account("port", "monteau", "wordplay@yahoo.biz")
    ```
  - fulfill a visit using the pal's ID and the visit's ID
    ```elixir
    Visilitator.fulfill_visit(2, "efb1be2d-676f-4353-851e-71b37e0506a7")
    ```
