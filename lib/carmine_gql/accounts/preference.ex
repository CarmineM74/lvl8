defmodule CarmineGql.Accounts.Preference do
  use Ecto.Schema
  import Ecto.Changeset
  alias CarmineGql.Accounts

  schema "preferences" do
    field :likes_emails, :boolean, default: false
    field :likes_phone_calls, :boolean, default: false
    field :likes_faxes, :boolean, default: false
    belongs_to :user, Accounts.User
  end

  @doc false
  def changeset(preference, attrs) do
    preference
    |> cast(attrs, [:likes_emails, :likes_phone_calls, :likes_faxes])
    |> validate_required([:likes_emails, :likes_phone_calls, :likes_faxes])
  end
end
