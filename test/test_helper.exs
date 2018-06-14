alias Ecto.Integration.Repo

defmodule Ecto.Integration.Repo do
  use Ecto.Repo, otp_app: :ecto_function
end

# Load up the repository, start it, and run migrations
_ = Ecto.Adapters.Postgres.storage_down(Repo.config())
:ok = Ecto.Adapters.Postgres.storage_up(Repo.config())

{:ok, pid} = Repo.start_link()

Code.require_file("support/migration.exs", __DIR__)

:ok = Ecto.Migrator.up(Repo, 0, Ecto.Integration.Migration, log: false)
Ecto.Adapters.SQL.Sandbox.mode(Repo, :manual)
Process.flag(:trap_exit, true)

:ok = Repo.stop(pid)
{:ok, _pid} = Repo.start_link()

ExUnit.start()
