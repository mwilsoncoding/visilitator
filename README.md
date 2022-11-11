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
  - Create a member user
  ```console
  iex(1)> Visilitator.create_account("bobby", "tables", "bobby.tables@gmail.com")
  Your user ID is: 658d9e5a-39d3-483e-9721-f4ae5df507b1
  :ok
  ```
  - Request a visit
  ```console
  iex(2)> Visilitator.request_visit("658d9e5a-39d3-483e-9721-f4ae5df507b1", "01-01-2023", 30, ["talk", "laundry"])
  Your visit ID is: efb1be2d-676f-4353-851e-71b37e0506a7
  :ok
  ```
  - Create a pal user
  ```console
  iex(3)> Visilitator.create_account("port", "monteau", "wordplay@yahoo.biz")    
  Your user ID is: c11b5228-c667-4295-b6e2-f8dae75372ef
  :ok
  ```
  - Fulfill a visit
  ```console
  iex(4)> Visilitator.fulfill_visit("c11b5228-c667-4295-b6e2-f8dae75372ef", "efb1be2d-676f-4353-851e-71b37e0506a7")
  Your transaction ID is: 6ffe01c0-c3a7-4b07-a184-216b4d72e84d
  :ok
  ```
