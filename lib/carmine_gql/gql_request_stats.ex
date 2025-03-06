defmodule CarmineGql.GqlRequestStats do
  use GenServer

  require Logger
  alias __MODULE__

  @moduledoc """
  Chosen strategy:
    - DeltaCRDT

  Why?
    - We are fine with eventual consistency 
      - we fall in the dashboard data case  
    - We want to have high Availability and Network partition tolerance
      - survivor nodes will serve the data in the event of a network split 
    - Our cluster is small
    - The amount of data to replicate across the cluster is small
  """

  def start_link(opts \\ []) do
    name = Keyword.get(opts, :name) || GqlRequestStats
    GenServer.start_link(__MODULE__, [], name: name)
  end

  @impl true
  def init(init_state) do
    {:ok, init_state, {:continue, :setup_crdt_cache}}
  end

  @impl true
  def handle_continue(:setup_crdt_cache, state) do
    Logger.debug("[Setup CRDT cache]")
    nodes = Node.list()

    if Enum.any?(nodes) do
      remote_crdt_caches = Enum.map(nodes, &{:crdt_cache, &1})
      local_crdt_cache = Process.whereis(:crdt_cache)
      DeltaCrdt.set_neighbours(:crdt_cache, remote_crdt_caches)
      Enum.each(remote_crdt_caches, &DeltaCrdt.set_neighbours(&1, [local_crdt_cache]))
    end

    {:noreply, state}
  end

  def get_hit_counter(nil), do: 0

  def get_hit_counter(request) when is_binary(request) do
    start = System.monotonic_time()

    result =
      case DeltaCrdt.get(:crdt_cache, request) do
        nil ->
          CarmineGql.Metrics.increment_counter_cache_miss()
          0

        counter ->
          CarmineGql.Metrics.increment_counter_cache_hit()
          counter
      end

    duration = System.monotonic_time() - start
    CarmineGql.Metrics.set_duration_for_counter_cache_get(duration)
    result
  end

  def hit(""), do: :ok
  def hit(nil), do: :ok

  def hit(request)
      when is_binary(request) do
    start = System.monotonic_time()
    current_value = get_hit_counter(request)
    DeltaCrdt.put(:crdt_cache, request, current_value + 1)
    duration = System.monotonic_time() - start
    CarmineGql.Metrics.set_duration_for_counter_cache_put(duration)
    :ok
  end
end
