defmodule CarmineGql.AuthTokensPipeline.UsersConsumer do
  require Logger
  alias CarmineGql.AuthTokenCache

  @default_token_ttl 86400

  def start_link(email) do
    Logger.debug("Starting UsersConsumer for #{email}")
    Task.start_link(fn -> generate_auth_tokens(email) end)
  end

  defp generate_auth_tokens(email) do
    ttl = Application.get_env(:carmine_gql, :auth_token_ttl, @default_token_ttl)
    auth_token = Base.encode64(:rand.bytes(12))
    Logger.debug("Caching auth token #{auth_token} for #{email}")
    AuthTokenCache.put(email, auth_token, ttl)
  end
end
