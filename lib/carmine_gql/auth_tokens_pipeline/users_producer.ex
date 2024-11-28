defmodule CarmineGql.AuthTokensPipeline.UsersProducer do
  use GenStage
  alias CarmineGql.AuthTokenCache
  alias CarmineGql.Accounts

  @fetch_interval Application.compile_env(:carmine_gql, :auth_token_ttl, 30)

  def start_link(_init_args) do
    GenStage.start_link(__MODULE__, nil, name: AuthTokenUsersProducer)
  end

  @impl true
  def init(_init_state) do
    send(AuthTokenUsersProducer, :populate)
    {:producer, []}
  end

  @impl true
  def handle_info(:populate, state) do
    AuthTokenCache.purge_stale_tokens()
    {:ok, users} = Accounts.all_users()
    ids = Enum.map(users, & &1.id)
    cached_tokens = AuthTokenCache.all() |> Enum.map(&elem(&1, 0))
    ids_to_authorize = Enum.reject(ids, &(&1 in cached_tokens))
    Process.send_after(AuthTokenUsersProducer, :populate, @fetch_interval * 1000)
    {:noreply, ids_to_authorize, state}
  end

  @impl true
  def handle_demand(demand, state) do
    events = Enum.take(state, demand)
    new_state = Enum.drop(state, demand)
    {:noreply, events, new_state}
  end
end
