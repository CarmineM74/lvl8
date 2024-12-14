defmodule CarmineGql.AuthTokenCache do
  alias CarmineGql.AuthTokenCache
  use Agent

  def start_link(_init_args) do
    Agent.start_link(
      fn ->
        :ets.new(:auth_token_cache, [
          :named_table,
          :set,
          :public,
          read_concurrency: true,
          write_concurrency: true
        ])
      end,
      name: AuthTokenCache
    )
  end

  def all(), do: :ets.tab2list(:auth_token_cache)

  def put(user_id, auth_token, ttl \\ 86400) do
    expiration = :os.system_time(:seconds) + ttl
    :ets.insert(:auth_token_cache, {user_id, auth_token, expiration})
  end

  def get_user(user_id) do
    case :ets.lookup(:auth_token_cache, user_id) do
      [{^user_id, _auth_token, _expiration} = user] -> {:ok, user}
      [] -> {:ok, ""}
    end
  end

  def get_user_from_token(auth_token) do
    pattern = [{{:"$1", :"$2", :"$3"}, [{:==, :"$2", auth_token}], [:"$1"]}]

    case :ets.select(:auth_token_cache, pattern) do
      [user_id] -> {:ok, user_id}
      [] -> {:error, :user_not_found}
    end
  end

  def purge_stale_tokens() do
    current_time = :os.system_time(:seconds)

    :ets.select_delete(:auth_token_cache, [
      {{:_, :_, :"$3"}, [{:"=<", :"$3", current_time}], [true]}
    ])
  end
end
