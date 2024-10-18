defmodule CarmineGqlWeb.Schema do
  use Absinthe.Schema
  alias CarmineGql.Repo
  alias CarmineGqlWeb.Schema.Middlewares

  import_types CarmineGqlWeb.Types.Preferences
  import_types CarmineGqlWeb.Types.User
  import_types CarmineGqlWeb.Schema.Queries.User
  import_types CarmineGqlWeb.Schema.Mutations.User
  import_types CarmineGqlWeb.Schema.Subscriptions.User

  query do
    import_fields :user_queries
  end

  mutation do
    import_fields :user_mutations
  end

  subscription do
    import_fields :user_subscriptions
  end

  def context(ctx) do
    source = Dataloader.Ecto.new(Repo)

    dataloader =
      Dataloader.new()
      |> Dataloader.add_source(CarmineGql.Accounts.User, source)

    Map.put(ctx, :loader, dataloader)
  end

  def plugins do
    [Absinthe.Middleware.Dataloader] ++ Absinthe.Plugin.defaults()
  end

  def middleware(middlewares, _field, %{identifier: identifier}) when identifier == :mutation do
    middlewares ++ [Middlewares.ChangesetErrors]
  end

  def middleware(middlewares, _field, _opts), do: middlewares
end
