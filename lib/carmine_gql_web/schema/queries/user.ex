defmodule CarmineGqlWeb.Schema.Queries.User do
  use Absinthe.Schema.Notation
  alias CarmineGqlWeb.Resolvers.Users

  object :user_queries do
    field :user, :user do
      arg :id, :id
      resolve &Users.by_id/2
    end

    field :users, list_of(:user) do
      arg :likes_emails, :boolean
      arg :likes_phone_calls, :boolean
      arg :likes_faxes, :boolean
      resolve &Users.by_preferences/2
    end

    field :resolver_hits, :integer do
      arg :key, non_null(:string)
      resolve &Users.resolver_hits/2
    end
  end
end
