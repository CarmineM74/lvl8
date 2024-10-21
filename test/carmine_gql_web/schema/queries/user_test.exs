defmodule CarmineGqlWeb.Schema.Queries.UserTest do
  use CarmineGql.DataCase, async: true

  alias CarmineGqlWeb.Schema
  alias CarmineGql.GqlRequestStats, as: Stats

  import CarmineGql.Support.UserFixtures

  setup do
    {:ok, _pid} = CarmineGql.GqlRequestStats.start_link(name: nil)
    :ok
  end

  @user_test_doc """
    query user($id: ID!) {
      user(id: $id) {
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

  describe "@user" do
    test "fetches an User by id" do
      assert {:ok, user} = create_user()

      assert {:ok, %{data: data}} =
               Absinthe.run(@user_test_doc, Schema,
                 variables: %{
                   "id" => user.id
                 }
               )

      assert data["user"]["id"] === to_string(user.id)
    end

    test "returns errors if no user is found" do
      assert {:ok, %{data: data, errors: errors}} =
               Absinthe.run(@user_test_doc, Schema,
                 variables: %{
                   "id" => 0
                 }
               )

      refute data["user"]
      error = Enum.find(errors, nil, &(&1.code === :not_found))
      assert error
    end

    test "fetching user by id increases user hit count" do
      assert 0 === Stats.get_hit_counter("user")

      Absinthe.run(@user_test_doc, Schema,
        variables: %{
          "id" => 1
        }
      )

      assert 1 === Stats.get_hit_counter("user")
    end
  end

  @users_test_doc """
    query users($likesEmails: Boolean, $likesPhoneCalls: Boolean, $likesFaxes: Boolean) {
      users(likesEmails: $likesEmails, likesPhoneCalls: $likesPhoneCalls, likesFaxes: $likesFaxes) {
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
  describe "@users" do
    test "Returns a list of users with given preferences" do
      {:ok, _user} = create_user()

      {:ok, _user} = create_user(%{preferences: %{likes_faxes: true}})

      assert {:ok, %{data: data}} =
               Absinthe.run(@users_test_doc, Schema,
                 variables: %{
                   "likesFaxes" => true
                 }
               )

      assert Enum.count(data["users"]) === 1
    end

    test "fetching users by id increases users hit count" do
      assert 0 === Stats.get_hit_counter("users")

      Absinthe.run(@users_test_doc, Schema,
        variables: %{
          "likesEmails" => true
        }
      )

      assert 1 === Stats.get_hit_counter("users")
    end
  end

  @resolver_hits_test_doc """
    query resolverHits($key: String!) {
      resolverHits(key: $key)
    }
  """
  describe "@resolverHits" do
    test "Querying always returns a number" do
      assert {:ok, %{data: data}} =
               Absinthe.run(@resolver_hits_test_doc, Schema,
                 variables: %{"key" => "unexisting-key"}
               )

      assert is_number(data["resolverHits"])
    end

    test "Querying an empty key returns 0" do
      assert {:ok, %{data: data}} =
               Absinthe.run(@resolver_hits_test_doc, Schema, variables: %{"key" => ""})

      assert 0 === data["resolverHits"]
    end

    test "Querying a nil key returns an error" do
      assert {:ok, %{errors: _errors}} =
               Absinthe.run(@resolver_hits_test_doc, Schema, variables: %{"key" => nil})
    end

    test "Querying a key that has been hit returns the current counter value" do
      {:ok, user} = create_user()

      {:ok, _} =
        Absinthe.run(@user_test_doc, Schema,
          variables: %{
            "id" => user.id
          }
        )

      assert {:ok, %{data: data}} =
               Absinthe.run(@resolver_hits_test_doc, Schema, variables: %{"key" => "user"})

      assert data["resolverHits"] === 1
    end

    test "Querying a key that has never been hit returns 0" do
      assert {:ok, %{data: data}} =
               Absinthe.run(@resolver_hits_test_doc, Schema, variables: %{"key" => "create_user"})

      assert data["resolverHits"] === 0
    end
  end
end
