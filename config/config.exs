# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
use Mix.Config

config :ecto_function, Ecto.Integration.Repo,
  adapter: Ecto.Adapters.Postgres,
  username: "postgres",
  password: "",
  hostname: "localhost",
  database: "ecto_function_test",
  pool: Ecto.Adapters.SQL.Sandbox
