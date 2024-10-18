defmodule CarmineGql.Support.UserFixtures do
  alias CarmineGql.Accounts

  def create_user(params \\ %{}) do
    random_suffix = :crypto.strong_rand_bytes(8) |> Base.url_encode64()

    default_params = %{
      name: "Test user",
      email: "test_#{random_suffix}@user.me",
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
