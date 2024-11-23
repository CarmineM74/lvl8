defmodule CarmineGqlWeb.Types.User do
  use Absinthe.Schema.Notation
  alias CarmineGql.Accounts
  alias CarmineGqlWeb.Resolvers
  import Absinthe.Resolution.Helpers, only: [dataloader: 2]

  @desc "User"
  object :user do
    field :id, :id
    field :name, :string
    field :email, :string
    field :preferences, :preferences, resolve: dataloader(Accounts.User, :preferences)
    field :auth_token, :string, resolve: &Resolvers.Users.fetch_auth_token/2
  end
end
