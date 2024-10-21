defmodule CarmineGqlWeb.Schema.Mutations.UserTest do
  use CarmineGql.DataCase

  alias CarmineGqlWeb.Schema
  alias CarmineGql.GqlRequestStats, as: Stats

  import CarmineGql.Support.UserFixtures

  setup do
    {:ok, _pid} = CarmineGql.GqlRequestStats.start_link(name: nil)
    :ok
  end

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
  describe "@createUser" do
    test "fails if no authentication is provided" do
      assert {:ok, %{errors: errors}} =
               Absinthe.run(@create_user_test_doc, Schema,
                 variables: %{
                   "name" => "TryMe",
                   "email" => "meh@me.com"
                 }
               )

      assert errors
      [auth_error] = errors
      assert auth_error
      assert auth_error.code === :internal_server_error
      assert auth_error.message === "authentication failed"
    end

    test "fails if token is not valid" do
      assert {:ok, %{errors: errors}} =
               Absinthe.run(@create_user_test_doc, Schema,
                 context: %{auth_token: "wrong_secret"},
                 variables: %{
                   "name" => "TryMe",
                   "email" => "meh@me.com"
                 }
               )

      assert errors
      [auth_error] = errors
      assert auth_error
      assert auth_error.code === :internal_server_error
      assert auth_error.message === "authentication failed"
    end

    test "Successfully creates an user with default preferences" do
      assert {:ok, %{data: data}} =
               Absinthe.run(@create_user_test_doc, Schema,
                 context: %{auth_token: "Imsecret"},
                 variables: %{
                   "name" => "Heisenberg",
                   "email" => "iamtheonewhoknocks@bb.com"
                 }
               )

      assert data["createUser"]["name"] === "Heisenberg"
      assert data["createUser"]["preferences"]["likesEmails"] === false
      assert data["createUser"]["preferences"]["likesPhoneCalls"] === false
      assert data["createUser"]["preferences"]["likesFaxes"] === false
    end

    test "fail if email has already been taken" do
      assert {:ok, user} = create_user()

      assert {:ok, %{errors: errors}} =
               Absinthe.run(@create_user_test_doc, Schema,
                 context: %{auth_token: "Imsecret"},
                 variables: %{
                   "name" => "Imposter",
                   "email" => user.email
                 }
               )

      conflict = Enum.find(errors, &(&1.code === :conflict))
      assert conflict
      assert %{details: %{email: _email_error}} = conflict
    end

    test "Supplying invalid data to createUser returns an error" do
      assert {:ok, %{errors: errors}} =
               Absinthe.run(@create_user_test_doc, Schema,
                 context: %{auth_token: "Imsecret"},
                 variables: %{
                   "name" => "Imposter"
                 }
               )

      assert Enum.count(errors) != 0
    end

    test "Creating an user increases create_user's hit count" do
      assert 0 === Stats.get_hit_counter("create_user")

      assert {:ok, %{data: _data}} =
               Absinthe.run(@create_user_test_doc, Schema,
                 context: %{auth_token: "Imsecret"},
                 variables: %{
                   "name" => "Heisenberg",
                   "email" => "iamtheonewhoknocks@bb.com"
                 }
               )

      assert 1 === Stats.get_hit_counter("create_user")
    end
  end

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
  describe "@updateUser" do
    test "fails if no authentication is provided" do
      assert {:ok, user} = create_user()

      assert {:ok, %{errors: errors}} =
               Absinthe.run(@update_user_test_doc, Schema,
                 variables: %{
                   "id" => to_string(user.id),
                   "name" => "TryMe"
                 }
               )

      assert errors
      [auth_error] = errors
      assert auth_error
      assert auth_error.code === :internal_server_error
      assert auth_error.message === "authentication failed"
    end

    test "fails if token is not valid" do
      assert {:ok, user} = create_user()

      assert {:ok, %{errors: errors}} =
               Absinthe.run(@update_user_test_doc, Schema,
                 context: %{auth_token: "wrong_secret"},
                 variables: %{
                   "id" => to_string(user.id),
                   "name" => "TryMe"
                 }
               )

      assert errors
      [auth_error] = errors
      assert auth_error
      assert auth_error.code === :internal_server_error
      assert auth_error.message === "authentication failed"
    end

    test "Updates user successfully" do
      assert {:ok, user} = create_user()

      assert {:ok, %{data: data}} =
               Absinthe.run(@update_user_test_doc, Schema,
                 context: %{auth_token: "Imsecret"},
                 variables: %{
                   "id" => to_string(user.id),
                   "name" => "Walter White"
                 }
               )

      assert data["updateUser"]["name"] === "Walter White"
    end

    test "Update fails without an id" do
      assert {:ok, %{errors: _errors}} =
               Absinthe.run(@update_user_test_doc, Schema,
                 context: %{auth_token: "Imsecret"},
                 variables: %{
                   "name" => "Walter White"
                 }
               )
    end

    test "fails when no user is found with given id" do
      assert {:ok, %{errors: errors}} =
               Absinthe.run(@update_user_test_doc, Schema,
                 context: %{auth_token: "Imsecret"},
                 variables: %{
                   "id" => "0",
                   "name" => "Walter White"
                 }
               )

      not_found = Enum.find(errors, &(&1.code === :not_found))
      assert not_found
    end

    test "Updating an user increases update_user's hit count" do
      assert 0 === Stats.get_hit_counter("update_user")
      assert {:ok, user} = create_user()

      assert {:ok, %{data: _data}} =
               Absinthe.run(@update_user_test_doc, Schema,
                 context: %{auth_token: "Imsecret"},
                 variables: %{
                   "id" => to_string(user.id),
                   "name" => "Updated"
                 }
               )

      assert 1 === Stats.get_hit_counter("update_user")
    end
  end

  @update_user_preferences_test_doc """
    mutation updateUserPreferences($userId: ID!, $likesEmails: Boolean, $likesPhoneCalls: Boolean, $likesFaxes: Boolean) {
      updateUserPreferences(userId: $userId, likesEmails: $likesEmails, likesPhoneCalls: $likesPhoneCalls, likesFaxes: $likesFaxes) {
        likesEmails
        likesFaxes
        likesPhoneCalls
        userId
    }
  }
  """
  describe "@updateUserPreferences" do
    test "fails if no authentication is provided" do
      assert {:ok, user} = create_user()

      assert {:ok, %{errors: errors}} =
               Absinthe.run(@update_user_preferences_test_doc, Schema,
                 variables: %{
                   "userId" => to_string(user.id),
                   "name" => "TryMe"
                 }
               )

      assert errors
      [auth_error] = errors
      assert auth_error
      assert auth_error.code === :internal_server_error
      assert auth_error.message === "authentication failed"
    end

    test "fails if a wrong token is provided" do
      assert {:ok, user} = create_user()

      assert {:ok, %{errors: errors}} =
               Absinthe.run(@update_user_preferences_test_doc, Schema,
                 context: %{auth_token: "wrong_secret"},
                 variables: %{
                   "userId" => to_string(user.id),
                   "name" => "TryMe"
                 }
               )

      assert errors
      [auth_error] = errors
      assert auth_error
      assert auth_error.code === :internal_server_error
      assert auth_error.message === "authentication failed"
    end

    test "Updates user preferences successfully" do
      assert {:ok, user} = create_user()

      assert {:ok, %{data: data}} =
               Absinthe.run(@update_user_preferences_test_doc, Schema,
                 context: %{auth_token: "Imsecret"},
                 variables: %{
                   "userId" => to_string(user.id),
                   "likesEmails" => !user.preferences.likes_emails
                 }
               )

      assert data["updateUserPreferences"]["likesEmails"] === !user.preferences.likes_emails
    end

    test "User preferences update fails when user is not found" do
      assert {:ok, %{errors: errors}} =
               Absinthe.run(@update_user_preferences_test_doc, Schema,
                 context: %{auth_token: "Imsecret"},
                 variables: %{
                   "userId" => "0",
                   "likesEmails" => false
                 }
               )

      not_found = Enum.find(errors, &(&1.code === :not_found))
      assert not_found
    end

    test "User preferences update fails when invalid data is supplied" do
      assert {:ok, user} = create_user()

      assert {:ok, %{errors: _errors}} =
               Absinthe.run(@update_user_preferences_test_doc, Schema,
                 context: %{auth_token: "Imsecret"},
                 variables: %{
                   "userId" => to_string(user.id),
                   "likesEmails" => "yes"
                 }
               )
    end

    test "Updating user preferences increases update_user's hit count" do
      assert 0 === Stats.get_hit_counter("update_user_preferences")
      assert {:ok, user} = create_user()

      assert {:ok, %{data: _data}} =
               Absinthe.run(@update_user_preferences_test_doc, Schema,
                 context: %{auth_token: "Imsecret"},
                 variables: %{
                   "userId" => to_string(user.id),
                   "likesEmails" => !user.preferences.likes_emails
                 }
               )

      assert 1 === Stats.get_hit_counter("update_user_preferences")
    end
  end
end
