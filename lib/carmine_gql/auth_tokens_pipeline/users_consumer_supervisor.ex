defmodule CarmineGql.AuthTokensPipeline.UsersConsumerSupervisor do
  use ConsumerSupervisor
  require Logger
  alias CarmineGql.AuthTokensPipeline.UsersConsumer

  @concurrent_consumers Application.compile_env(:carmine_gql, :users_consumer_max_demand, 2)

  def start_link(_init_args) do
    Logger.debug("UsersConsumerSupervisor starting")
    ConsumerSupervisor.start_link(__MODULE__, :ok)
  end

  @impl true
  def init(:ok) do
    children = [
      %{
        id: UserConsumer,
        start: {UsersConsumer, :start_link, []},
        restart: :transient
      }
    ]

    opts = [
      strategy: :one_for_one,
      subscribe_to: [{AuthTokenUsersProducer, max_demand: @concurrent_consumers}]
    ]

    ConsumerSupervisor.init(children, opts)
  end
end
