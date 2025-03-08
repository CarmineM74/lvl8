defmodule CarmineGqlWeb.Schema.Mutations.UserTest do
  use CarmineGql.DataCase

  alias CarmineGqlWeb.Schema
  alias CarmineGql.GqlRequestStats, as: Stats

  import CarmineGql.Support.UserFixtures
  import CarmineGql.Test.Support, only: [test_failure_with_error: 2]

  setup do
    start_supervised!({CarmineGql.GqlRequestStats, [cache_module: CarmineGql.Caches.DCrdt]})
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
      variables = %{
        "name" => "TryMe",
        "email" => "meh@me.com"
      }

      test_failure_with_error(@create_user_test_doc,
        error_message: "authentication failed",
        variables: variables
      )
    end

    test "fails if token is not valid" do
      context = %{auth_token: "wrong_secret"}

      variables = %{
        "name" => "TryMe",
        "email" => "meh@me.com"
      }

      test_failure_with_error(
        @create_user_test_doc,
        error_message: "authentication failed",
        context: context,
        variables: variables
      )
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
      context = %{auth_token: "Imsecret"}

      variables = %{
        "name" => "TryMe",
        "email" => user.email
      }

      test_failure_with_error(
        @create_user_test_doc,
        error_message: "email conflict on insert",
        error_code: :conflict,
        context: context,
        variables: variables
      )
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

      variables = %{
        "id" => to_string(user.id),
        "name" => "TryMe"
      }

      test_failure_with_error(
        @update_user_test_doc,
        error_message: "authentication failed",
        variables: variables
      )
    end

    test "fails if token is not valid" do
      assert {:ok, user} = create_user()

      context = %{auth_token: "not_valid"}

      variables = %{
        "id" => to_string(user.id),
        "name" => "TryMe"
      }

      test_failure_with_error(
        @update_user_test_doc,
        error_message: "authentication failed",
        context: context,
        variables: variables
      )
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
      variables = %{
        "id" => "0",
        "name" => "Walter White"
      }

      test_failure_with_error(
        @update_user_test_doc,
        error_code: :not_found,
        context: %{auth_token: "Imsecret"},
        variables: variables
      )
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
    setup do
      {:ok, user} = create_user()
      %{user: user}
    end

    test "fails if no authentication is provided", %{user: user} do
      variables = %{
        "userId" => to_string(user.id),
        "name" => "TryMe"
      }

      test_failure_with_error(@update_user_preferences_test_doc,
        error_message: "authentication failed",
        variables: variables
      )
    end

    test "fails if a wrong token is provided", %{user: user} do
      variables = %{
        "userId" => to_string(user.id),
        "name" => "TryMe"
      }

      test_failure_with_error(@update_user_preferences_test_doc,
        error_message: "authentication failed",
        context: %{auth_token: "wrong_secret"},
        variables: variables
      )
    end

    test "Updates user preferences successfully", %{user: user} do
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
      variables = %{
        "userId" => "0",
        "likesEmails" => false
      }

      test_failure_with_error(@update_user_preferences_test_doc,
        error_code: :not_found,
        context: %{auth_token: "Imsecret"},
        variables: variables
      )
    end

    test "User preferences update fails when invalid data is supplied", %{user: user} do
      assert {:ok, %{errors: _errors}} =
               Absinthe.run(@update_user_preferences_test_doc, Schema,
                 context: %{auth_token: "Imsecret"},
                 variables: %{
                   "userId" => to_string(user.id),
                   "likesEmails" => "yes"
                 }
               )
    end

    test "Updating user preferences increases update_user's hit count", %{user: user} do
      assert 0 === Stats.get_hit_counter("update_user_preferences")

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
