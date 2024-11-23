defmodule CarmineGql.AuthTokenCache do
  alias CarmineGql.AuthTokenCache
  use GenServer

  require Logger

  def start_link(_init_args) do
    Logger.debug("AuthTokenCache starting")

    :ets.new(:auth_token_cache, [
      :named_table,
      :set,
      :public,
      read_concurrency: true,
      write_concurrency: true
    ])

    GenServer.start_link(__MODULE__, nil, name: AuthTokenCache)
  end

  def all(), do: :ets.tab2list(:auth_token_cache)

  def put(user_email, auth_token, ttl \\ 86400) do
    expiration = :os.system_time(:seconds) + ttl
    :ets.insert(:auth_token_cache, {user_email, auth_token, expiration})
  end

  def get(user_email) do
    case :ets.lookup(:auth_token_cache, user_email) do
      [{^user_email, auth_token, _expiration}] -> {:ok, auth_token}
      [] -> {:ok, ""}
    end
  end

  def purge_stale_tokens() do
    Logger.debug("Purging stale auth tokens from cache")
    current_time = :os.system_time(:seconds)

    :ets.select_delete(:auth_token_cache, [
      {{:_, :_, :"$3"}, [{:"=<", :"$3", current_time}], [true]}
    ])
  end

  @impl true
  def init(init_state) do
    {:ok, init_state}
  end
end
