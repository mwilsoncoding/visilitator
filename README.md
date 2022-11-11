# container-dev-elixir

An opinionated starting point for containerized development in Elixir.

## How to Use

- Follow [the official instructions](https://docs.github.com/en/repositories/creating-and-managing-repositories/creating-a-repository-from-a-template) on creating a new repo from a template.
- Modify new repository settings accordingly

```console
# After creating $MY_NEW_REPO from this template
git clone $MY_NEW_REPO
```
```console
cd $MY_NEW_REPO
```
```console
docker run \
  --rm \
  -it \
  -v $(pwd):/workspace \
  -w /workspace \
  --entrypoint sh
  -e OTP_APP=my_app \
  -e MODULE=MyApp \
  alpine:latest \
  -c 'sed -i -e "s/elixir_dev/${OTP_APP}/g" .gitignore mix.exs && sed -i -e "s/ElixirDev/${MODULE}/g" lib/elixir_dev.ex test/elixir_dev_test.exs mix.exs && mv ./lib/elixir_dev.ex ./lib/${OTP_APP}.ex && mv ./test/elixir_dev_test.exs ./test/${OTP_APP}_test.exs'
```
