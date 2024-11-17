defmodule CarmineGql.AuthTokensPipeline.UsersProducer do
  use GenStage
  alias CarmineGql.AuthTokenCache
  alias CarmineGql.Accounts

  @fetch_interval 30000

  def start_link(_init_args) do
    GenStage.start_link(__MODULE__, nil, name: AuthTokenUsersProducer)
  end

  @impl true
  def init(_init_state) do
    Logger.debug("Initializing")
    send(AuthTokenUsersProducer, :populate)
    {:producer, []}
  end

  @impl true
  def handle_info(:populate, state) do
    AuthTokenCache.expire_stale_tokens()
    users_to_authorize = Enum.map(AuthTokenCache.all(), &(elem(&1, 1)))
    {:ok, emails_to_authorize} = Accounts.users_by_email(in: users_to_authorize)
    Process.send_after(AuthTokenUsersProducer, :populate, @fetch_interval)
    {:noreply, emails_to_authorize, state}
  end

  @impl true
  def handle_demand(demand, state) do
    events = Enum.take(state, demand)
    new_state = Enum.drop(state, demand)
    {:noreply, events, new_state}
  end
end
