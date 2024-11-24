defmodule CarmineGqlWeb.Resolvers.Users do
  alias CarmineGql.Accounts
  alias CarmineGql.GqlRequestStats, as: Stats
  alias CarmineGql.AuthTokenCache

  def by_id(%{id: id}, _resolution) do
    Stats.hit("user")
    Accounts.user_by_id(id)
  end

  def by_preferences(preferences_params, _resolution) do
    Stats.hit("users")
    Accounts.user_by_preferences(preferences_params)
  end

  def create_user(params, _resolution) do
    Stats.hit("create_user")
    Accounts.create_user(params)
  end

  def update_user(%{id: id} = params, _resolution) do
    Stats.hit("update_user")
    Accounts.update_user(id, params)
  end

  def update_user_preferences(%{user_id: id} = preferences, _resolution) do
    Stats.hit("update_user_preferences")
    Accounts.update_user_preferences(id, preferences)
  end

  def resolver_hits(%{key: key}, _resolution), do: {:ok, Stats.get_hit_counter(key)}

  def fetch_auth_token(_args, resolution) do
    AuthTokenCache.get(%{user_id: resolution.source.id})
  end

  def fetch_user_from_auth_token(%{auth_token: auth_token}, _resolution) do
    {:ok, user_id} = AuthTokenCache.get(%{auth_token: auth_token})
    Accounts.user_by_id(user_id)
  end
end
