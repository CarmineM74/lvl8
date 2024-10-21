defmodule CarmineGql.Schema.Subscriptions.UserTest do
  use CarmineGqlWeb.SubscriptionCase
  use CarmineGql.DataCase

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

  @created_user_test_doc """
    subscription createdUser {
      createdUser {
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
  describe "@createdUser" do
    test "fails when socket has not been authenticated", %{socket: socket} do
      ref = push_doc(socket, @created_user_test_doc)
      assert_reply(ref, :ok, %{subscriptionId: _subscription_id})

      ref =
        push_doc(socket, @create_user_test_doc,
          variables: %{
            "name" => "Observed",
            "email" => "theyrwatching@me.com"
          }
        )

      assert_reply(ref, :ok, reply)

      assert %{data: %{"createUser" => nil}, errors: errors} = reply
      auth_error = Enum.find(errors, &(&1.message === "authentication failed"))
      assert auth_error
    end

    test "Returns an user when @createUser is mutation is triggered", %{socket: socket} do
      socket = authenticate_socket(socket)
      ref = push_doc(socket, @created_user_test_doc)
      assert_reply(ref, :ok, %{subscriptionId: subscription_id})

      ref =
        push_doc(socket, @create_user_test_doc,
          variables: %{
            "name" => "Observed",
            "email" => "theyrwatching@me.com"
          }
        )

      assert_reply(ref, :ok, reply)

      assert %{
               data: %{
                 "createUser" => %{
                   "name" => "Observed",
                   "email" => "theyrwatching@me.com"
                 }
               }
             } = reply

      assert_push("subscription:data", data)

      user_id = reply.data["createUser"]["id"]

      assert %{
               subscriptionId: ^subscription_id,
               result: %{
                 data: %{
                   "createdUser" => %{
                     "id" => ^user_id,
                     "name" => "Observed",
                     "email" => "theyrwatching@me.com"
                   }
                 }
               }
             } = data
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

  @updated_user_preferences_test_doc """
    subscription updatedUserPreferences($userId: ID!) {
      updatedUserPreferences(userId: $userId) {
        likesEmails
        likesFaxes
        likesPhoneCalls
        userId
      }
    }
  """
  describe "@updatedUserPreferences" do
    @tag :wip
    test "fails when socket has not been authenticated", %{socket: socket} do
      ref =
        push_doc(socket, @updated_user_preferences_test_doc, %{
          variables: %{"userId" => "0"}
        })

      assert_reply(ref, :ok, %{subscriptionId: _subscription_id})

      ref =
        push_doc(socket, @update_user_preferences_test_doc,
          variables: %{
            "userId" => "0",
            "likesFaxes" => false
          }
        )

      assert_reply(ref, :ok, reply)

      assert %{data: %{"updateUserPreferences" => nil}, errors: errors} = reply
      auth_error = Enum.find(errors, &(&1.message === "authentication failed"))
      assert auth_error
    end

    test "Returns user's preferences when @updateUserPreferences mutation is triggered", %{
      socket: socket
    } do
      {:ok, user} = create_user(%{preferences: %{likes_faxes: true}})

      user_id = to_string(user.id)

      socket = authenticate_socket(socket)

      ref =
        push_doc(socket, @updated_user_preferences_test_doc, %{
          variables: %{"userId" => user_id}
        })

      assert_reply(ref, :ok, %{subscriptionId: subscription_id})

      push_doc(socket, @update_user_preferences_test_doc, %{
        variables: %{
          "userId" => user_id,
          "likesFaxes" => false
        }
      })

      assert_push("subscription:data", data)

      assert %{
               subscriptionId: ^subscription_id,
               result: %{
                 data: %{
                   "updatedUserPreferences" => %{
                     "userId" => ^user_id,
                     "likesFaxes" => false,
                     "likesEmails" => _,
                     "likesPhoneCalls" => _
                   }
                 }
               }
             } = data
    end
  end

  defp authenticate_socket(socket, token \\ "Imsecret") do
    socket =
      Absinthe.Phoenix.Socket.put_options(socket,
        context: %{auth_token: token, pubsub: CarmineGqlWeb.Endpoint}
      )

    {:ok, socket} = Absinthe.Phoenix.SubscriptionTest.join_absinthe(socket)
    socket
  end
end
