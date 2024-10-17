defmodule CarmineGqlWeb.Types.User do
  use Absinthe.Schema.Notation
  alias CarmineGql.Accounts
  import Absinthe.Resolution.Helpers, only: [dataloader: 2]

  @desc "User"
  object :user do
    field :id, :id
    field :name, :string
    field :email, :string
    field :preferences, :preferences, resolve: dataloader(Accounts.User, :preferences)
  end
end
