defmodule CarmineGql.Support.UserFixtures do
  alias CarmineGql.Accounts

  def create_user(params \\ %{}) do
    default_params = %{
      name: "Test user",
      email: "test@user.me",
      preferences: %{
        likes_emails: true,
        likes_faxes: false,
        likes_phone_calls: false
      }
    }

    params =
      Map.merge(default_params, params, fn _, nested1, nested2 -> Map.merge(nested1, nested2) end)

    Accounts.create_user(params)
  end
end
