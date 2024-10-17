defmodule CarmineGql.DataCase do
  use ExUnit.CaseTemplate

  using do
    quote do
      alias CarmineGql.Repo
      import Ecto
      import Ecto.Query
      import CarmineGql.DataCase
    end
  end

  setup tags do
    :ok = Ecto.Adapters.SQL.Sandbox.checkout(CarmineGql.Repo)

    unless tags[:async] do
      Ecto.Adapters.SQL.Sandbox.mode(CarmineGql.Repo, {:shared, self()})
    end

    :ok
  end
end
