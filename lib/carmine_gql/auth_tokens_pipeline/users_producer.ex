defmodule CarmineGql.AuthTokensPipeline.UsersProducer do
  use GenStage
  alias CarmineGql.AuthTokenCache
  alias CarmineGql.Accounts

  @fetch_interval Application.compile_env(:carmine_gql, :auth_token_ttl, 30)

  def start_link(_init_args) do
    GenStage.start_link(__MODULE__, %{stream_offset: 0, demand: 0}, name: AuthTokenUsersProducer)
  end

  @impl true
  def init(init_state) do
    send(self(), :purge)
    {:producer, init_state}
  end

  def new_user_created(id) do
    GenStage.cast(AuthTokenUsersProducer, {:new_user_created, id})
  end

  def handle_cast({:new_user_created, id}, state) do
    {:noreply, [id], state}
  end

  @impl true
  def handle_info(:purge, state) do
    Process.send_after(self(), :purge,  1000)
    AuthTokenCache.purge_stale_tokens()
    {new_state, events} = state
      |> fetch_data()
      |> slide_window()
    {:noreply, events, new_state}
  end

  @impl true
  def handle_demand(demand, state) do
    {:noreply, [], %{state| demand: demand}}
  end

  defp fetch_data(state) do
    {:ok, users} = Accounts.all_users(%{offset: state.stream_offset, limit: state.demand})
    ids = Enum.map(users, & &1.id)
    cached_tokens = AuthTokenCache.all() |> Enum.map(&elem(&1, 0))
    ids_to_authorize = Enum.reject(ids, &(&1 in cached_tokens))
    {state, ids_to_authorize}
  end

  defp slide_window({state, ids_to_authorize}) do
    users_count = Accounts.users_count()
    new_offset = Integer.mod(state.stream_offset + state.demand, users_count + 1)
    new_state = %{state | stream_offset: new_offset}
    {new_state, ids_to_authorize}
  end
end
