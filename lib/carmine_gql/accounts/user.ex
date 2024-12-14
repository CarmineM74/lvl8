defmodule CarmineGql.Accounts.User do
  use Ecto.Schema
  import Ecto.Changeset
  import Ecto.Query
  alias __MODULE__
  alias CarmineGql.Accounts

  schema "users" do
    field :name, :string
    field :email, :string
    has_one :preferences, Accounts.Preference
  end

  @doc false
  def changeset(user, attrs) do
    user
    |> cast(attrs, [:name, :email])
    |> validate_required([:name, :email])
    |> cast_assoc(:preferences)
    |> unique_constraint(:email)
    |> validate_format(:email, ~r/@/)
  end

  def with_preferences(), do: from(u in User, join: p in assoc(u, :preferences))

  def filter_by_email(criteria) do
    Enum.reduce(criteria, User.with_preferences(), &User.apply_email_filter/2)
  end

  def apply_email_filter(_params, query \\ User)

  def apply_email_filter({:not_in, values}, query) when is_list(values) and length(values) > 0,
    do: where(query, [u, _p], u.email not in ^values)

  def apply_email_filter({:not_in, _values}, query), do: query

  def apply_email_filter({:in, values}, query) when is_list(values) and length(values) > 0,
    do: where(query, [u, _p], u.email in ^values)

  def apply_email_filter({:in, _values}, query), do: query

  def filter_by_preferences(preferences) do
    Enum.reduce(preferences, User.with_preferences(), &User.apply_preferences_filter/2)
  end

  def apply_preferences_filter(_params, query \\ User)

  def apply_preferences_filter({preference_field, value}, query),
    do: where(query, [_u, p], field(p, ^preference_field) == ^value)
end
