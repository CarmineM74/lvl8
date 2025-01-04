defmodule CarmineGql.Stress do
  alias CarmineGqlWeb.Schema
  alias CarmineGql.Accounts
  alias CarmineGql.Repo

  @create_user_test_doc """
    mutation createUser($id: ID, $name: String!, $email: String!, $preferences: PreferencesInput) {
      createUser(id: $id, name: $name, email: $email, preferences: $preferences) {
      id
      name
      email
      preferences {
        likesEmails
        likesFaxes
        likesPhoneCalls
        userId
      }
    }
  }
  """

  @update_user_test_doc """
    mutation updateUser($id: ID!, $name: String, $email: String) {
      updateUser(id: $id, name: $name, email: $email) {
      id
      name
      email
      preferences {
        likesEmails
        likesFaxes
        likesPhoneCalls
        userId
      }
    }
  }
  """

  def stress_gql(iterations \\ 100) do
    Enum.each(1..iterations, fn _ ->
      Process.sleep(:rand.uniform(iterations))
      op = :rand.uniform(100)

      user = pick_random_user()

      cond do
        is_nil(user) or op < 30 ->
          create_user()

        op < 60 ->
          update_user_gql(user)

        true ->
          update_user_ecto(user)
      end
    end)
  end

  def pick_random_user() do
    Accounts.all_users()
    |> then(fn {:ok, users} -> users end)
    |> Enum.shuffle()
    |> List.first()
    |> Repo.preload(:preferences)
  end

  def create_user() do
    suffix = Base.encode64(:rand.bytes(10))

    Absinthe.run(@create_user_test_doc, Schema,
      context: %{auth_token: "Imsecret"},
      variables: %{
        "name" => "stressed_#{suffix}",
        "email" => "#{suffix}@stressed.com"
      }
    )
  end

  def update_user_gql(user) do
    op = :rand.uniform(100)
    suffix = Base.encode64(:rand.bytes(10))

    variables =
      cond do
        op < 50 ->
          %{name: "stressed_" <> suffix}

        op >= 50 ->
          %{email: suffix <> "@stressed.com"}
      end

    Absinthe.run(@update_user_test_doc, Schema,
      context: %{auth_token: "Imsecret"},
      variables: Map.put(variables, "id", to_string(user.id))
    )
  end

  def update_user_ecto(user) do
    op = :rand.uniform(100)

    cond do
      op < 30 ->
        update_user_name(user)

      op >= 30 and op < 60 ->
        update_user_preferences(user)

      true ->
        update_user_email(user)
    end
  end

  defp update_user_name(user) do
    new_name = "stressed_" <> Base.encode64(:rand.bytes(10))
    Accounts.update_user(user.id, %{name: new_name})
  end

  defp update_user_preferences(user) do
    new_preferences = %{
      Map.from_struct(user.preferences)
      | likes_emails: !user.preferences.likes_emails,
        likes_faxes: !user.preferences.likes_faxes,
        likes_phone_calls: !user.preferences.likes_phone_calls
    }

    Accounts.update_user_preferences(user.id, new_preferences)
  end

  defp update_user_email(user) do
    new_email = Base.encode64(:rand.bytes(10)) <> "@stressed.com"
    Accounts.update_user(user.id, %{email: new_email})
  end
end
