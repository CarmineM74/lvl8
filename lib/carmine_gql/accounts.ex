defmodule CarmineGql.Accounts do
  alias CarmineGqlWeb.Schema.Mutations.User
  alias CarmineGql.Accounts.{User, Preference}
  alias CarmineGql.Repo
  alias EctoShorts.Actions
  alias CarmineGql.ErrorUtils

  def user_by_id(id) do
    case Actions.get(User, id) do
      nil ->
        {:error, ErrorUtils.not_found("user not found", %{id: id})}

      user ->
        {:ok, user}
    end
  end

  def user_by_preferences(preferences \\ %{}) do
    users = Actions.all(User.filter_by_preferences(preferences))
    {:ok, users}
  end

  def create_user(params \\ %{}) do
    params = maybe_set_default_preferences(params)

    case Actions.create(User, params) do
      {:error, %Ecto.Changeset{} = changeset} ->
        {:error, changeset}

      {:ok, user} ->
        {:ok, user}
    end
  end

  defp maybe_set_default_preferences(attrs) do
    default_preferences = %{
      likes_emails: false,
      likes_phone_calls: false,
      likes_faxes: false
    }

    preferences = Map.merge(default_preferences, Map.get(attrs, :preferences, %{}))

    Map.put(attrs, :preferences, preferences)
  end

  def update_user(id, params \\ %{}) do
    case Actions.update(User, id, params) do
      {:error, %Ecto.Changeset{} = changeset} ->
        {:error, changeset}

      {:error, %ErrorMessage{} = error_message} ->
        {:error, ErrorMessage.to_jsonable_map(error_message)}

      {:ok, user} ->
        {:ok, user}
    end
  end

  def update_user_preferences(id, %{} = preferences) do
    with {:ok, user} <- user_by_id(id),
         user <- Repo.preload(user, :preferences),
         {:ok, updated_preferences} <-
           Actions.update(Preference, user.preferences.id, preferences) do
      {:ok, updated_preferences}
    else
      {:error, %ErrorMessage{} = error_message} ->
        {:error, ErrorMessage.to_jsonable_map(error_message)}

      {:error, error} ->
        {:error, error}
    end
  end
end
