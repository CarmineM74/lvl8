defmodule CarmineGql.Repo do
  use Ecto.Repo,
    otp_app: :carmine_gql,
    adapter: Ecto.Adapters.Postgres
end
