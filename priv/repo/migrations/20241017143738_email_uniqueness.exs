defmodule CarmineGql.Repo.Migrations.EmailUniqueness do
  use Ecto.Migration

  def change do
    unique_index(:users, [:email])

  end
end
