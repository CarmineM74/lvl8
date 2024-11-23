defmodule CarmineGql.AuthTokensPipeline.UsersConsumer do
  require Logger
  alias CarmineGql.AuthTokenCache

  @default_token_ttl 86400

  def start_link(id) do
    Logger.debug("Starting UsersConsumer for #{id}")
    Task.start_link(fn -> generate_auth_tokens(id) end)
  end

  defp generate_auth_tokens(id) do
    ttl = Application.get_env(:carmine_gql, :auth_token_ttl, @default_token_ttl)
    auth_token = Base.encode64(:rand.bytes(12))
    Logger.debug("Caching auth token #{auth_token} for #{id}")
    AuthTokenCache.put(id, auth_token, ttl)
    Absinthe.Subscription.publish(CarmineGqlWeb.Endpoint, auth_token, user_auth_token: id)
  end
end
