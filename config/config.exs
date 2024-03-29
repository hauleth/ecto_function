# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
use Mix.Config

config :logger, level: :warn

config :ecto_function, Ecto.Integration.Repo,
  username: "postgres",
  password: "postgres",
  database: "ecto_function_test",
  pool: Ecto.Adapters.SQL.Sandbox
