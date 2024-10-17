defmodule CarmineGqlWeb.Types.Preferences do
  use Absinthe.Schema.Notation

  @desc "User's contact preferences"
  object :preferences do
    field :user_id, :id
    field :likes_emails, :boolean
    field :likes_phone_calls, :boolean
    field :likes_faxes, :boolean
  end

  input_object :preferences_input do
    field :likes_emails, :boolean
    field :likes_phone_calls, :boolean
    field :likes_faxes, :boolean
  end
end
