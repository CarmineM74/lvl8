defmodule CarmineGqlWeb.Schema.Mutations.User do
  use Absinthe.Schema.Notation
  alias CarmineGqlWeb.Resolvers.Users
  alias CarmineGqlWeb.Schema.Middlewares

  object :user_mutations do
    field :create_user, :user do
      arg :id, :id
      arg :name, :string
      arg :email, :string
      arg :preferences, :preferences_input
      middleware Middlewares.Auth, secret_key: "Imsecret"
      resolve &Users.create_user/2
    end

    field :update_user, :user do
      arg :id, :id
      arg :name, :string
      arg :email, :string
      middleware Middlewares.Auth, secret_key: "Imsecret"
      resolve &Users.update_user/2
    end

    field :update_user_preferences, :preferences do
      arg :user_id, :id
      arg :likes_emails, :boolean
      arg :likes_phone_calls, :boolean
      arg :likes_faxes, :boolean
      middleware Middlewares.Auth, secret_key: "Imsecret"
      resolve &Users.update_user_preferences/2
    end
  end
end
