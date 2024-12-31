defmodule CarmineGql.AuthTokensPipeline.UsersConsumer do
  require Logger
  alias CarmineGql.AuthTokenCache

  @default_token_ttl 86400

  def start_link(id) do
    Logger.debug("Starting UsersConsumer for #{id}")
    Task.start_link(fn -> generate_auth_tokens(id) end)
  end

  defp generate_auth_tokens(id) do
    id
    |> AuthTokenCache.get_user()
    |> refresh_required?()
    |> maybe_refresh_auth_token(id)
  end

  def refresh_required?({:ok, ""}), do: :refresh

  def refresh_required?({:ok, {_id, _token, expiration}}) do
    current_time = :os.system_time(:seconds)

    if current_time >= expiration do
      :refresh
    else
      :no_refresh_needed
    end
  end

  def maybe_refresh_auth_token(:no_refresh_needed, _id), do: :ok

  def maybe_refresh_auth_token(:refresh, id) do
    start = System.monotonic_time()
    ttl = Application.get_env(:carmine_gql, :auth_token_ttl, @default_token_ttl)
    auth_token = Base.encode64(:rand.bytes(12))
    Logger.debug("Caching auth token #{auth_token} for #{id}")
    AuthTokenCache.put(id, auth_token, ttl)
    Absinthe.Subscription.publish(CarmineGqlWeb.Endpoint, auth_token, user_auth_token: id)
    duration = System.monotonic_time() - start
    CarmineGql.Metrics.increment_auth_tokens_generated()
    CarmineGql.Metrics.set_duration_for_auth_token_generation(duration)
    :ok
  end
end
