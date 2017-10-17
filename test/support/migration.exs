defmodule Ecto.Integration.Migration do
  use Ecto.Migration

  def change do
    create table(:example) do
      add :value, :numeric
    end
  end
end
