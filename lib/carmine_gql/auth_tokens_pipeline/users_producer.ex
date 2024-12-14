defmodule CarmineGql.AuthTokensPipeline.UsersProducer do
  use GenStage
  require Logger
  alias CarmineGql.Accounts

  @fetch_interval Application.compile_env(:carmine_gql, :auth_token_ttl, 30)
  @max_demand Application.compile_env(:carmine_gql, :users_consumer_max_demand, 2)

  def start_link(_init_args) do
    GenStage.start_link(__MODULE__, %{stream_offset: 0, users_count: 0},
      name: AuthTokenUsersProducer
    )
  end

  @impl true
  def init(init_state) do
    Process.send_after(self(), :refresh_auth_tokens, @fetch_interval * 1000)
    {:producer, %{init_state | users_count: Accounts.users_count()}}
  end

  def new_user_created(id) do
    GenStage.cast(AuthTokenUsersProducer, {:new_user_created, id})
  end

  @impl true
  def handle_cast({:new_user_created, id}, state) do
    {:noreply, [id], state}
  end

  @impl true
  def handle_info(:refresh_auth_tokens, state) do
    Process.send_after(self(), :refresh_auth_tokens, @fetch_interval * 1000)
    handle_demand(@max_demand, %{state | stream_offset: 0, users_count: Accounts.users_count()})
  end

  @impl true
  def handle_demand(demand, state) do
    {state, events} =
      state
      |> fetch_data(demand)
      |> slide_window(demand)

    {:noreply, events, state}
  end

  defp fetch_data(state, demand) do
    {:ok, users} = Accounts.all_users(%{offset: state.stream_offset, limit: demand})
    ids = Enum.map(users, & &1.id)
    {state, ids}
  end

  defp slide_window({state, ids_to_authorize}, demand) do
    new_state = %{state | stream_offset: state.stream_offset + demand}
    {new_state, ids_to_authorize}
  end
end
