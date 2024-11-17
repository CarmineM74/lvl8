defmodule CarmineGql.AuthTokenCache do
  use GenServer

  @token_ttl 86400

  def start_link(_init_args) do
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

  def expire_stale_tokens() do
    current_time = :os.system_time(:seconds)
    :ets.select_delete(:auth_token_cache, [{{:_, :_, :"$3"}, [{:"=<", :"$3", current_time}], [true]}])
  end

  def put(user_email, auth_token) do
    expiration = :os.system_time(:seconds) + @token_ttl
    :ets.insert(:auth_token_cache, {user_email, auth_token, expiration})
  end

  def get(user_email) do
    case :ets.lookup(:auth_token_cache, user_email) do
      [{^user_email, auth_token, _expiration}] -> {:ok, auth_token}
      [] -> {:error, :missing_auth_token}
    end
  end

  @impl true
  def init(init_state) do
    {:ok, init_state}
  end
end
