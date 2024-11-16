defmodule CarmineGql.AuthTokenCache do
  use GenServer

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

  def put(user_email, auth_token) do
    :ets.insert(:auth_token_cache, {user_email, auth_token})
  end

  def get(user_email) do
    case :ets.lookup(:auth_token_cache, user_email) do
      [{^user_email, auth_token}] -> {:ok, auth_token}
      [] -> {:error, :missing_auth_token}
    end
  end

  @impl true
  def init(init_state) do
    {:ok, init_state}
  end
end
