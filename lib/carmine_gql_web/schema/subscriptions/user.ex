defmodule CarmineGqlWeb.Schema.Subscriptions.User do
  use Absinthe.Schema.Notation

  object :user_subscriptions do
    field :created_user, :user do
      config fn _, _ ->
        {:ok, topic: "new_user"}
      end

      trigger :create_user,
        topic: fn _ ->
          "new_user"
        end
    end

    field :updated_user_preferences, :preferences do
      arg :user_id, :id

      config fn args, _ ->
        {:ok, topic: args.user_id}
      end

      trigger :update_user_preferences,
        topic: fn preferences ->
          preferences.user_id
        end
    end

    field :user_auth_token, :string do
      arg :user_id, :id

      config fn args, _ ->
        {:ok, topic: args.user_id}
      end
    end
  end
end
