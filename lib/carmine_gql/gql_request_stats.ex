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
    cache = Keyword.get(opts, :cache_module) || CarmineGql.Caches.DCrdt
    GenServer.start_link(__MODULE__, %{cache: cache}, name: GqlRequestStats)
  end

  @impl true
  def init(init_state) do
    {:ok, init_state, {:continue, :setup_cache}}
  end

  @impl true
  def handle_continue(:setup_cache, %{cache: cache} = state) do
    cache.setup()
    {:noreply, state}
  end

  def get_hit_counter(nil), do: 0

  def get_hit_counter(request) when is_binary(request),
    do: GenServer.call(GqlRequestStats, {:get, request})

  def hit(""), do: :ok
  def hit(nil), do: :ok

  def hit(request)
      when is_binary(request) do
    GenServer.cast(GqlRequestStats, {:hit, request})
  end

  @impl true
  def handle_call({:get, request}, _from, %{cache: cache} = state) do
    start = System.monotonic_time()

    result = fetch_from_cache(cache, request)
    duration = System.monotonic_time() - start

    CarmineGql.Metrics.set_duration_for_counter_cache_get(duration)
    {:reply, result, state}
  end

  @impl true
  def handle_cast({:hit, request}, %{cache: cache} = state) do
    start = System.monotonic_time()
    current_value = fetch_from_cache(cache, request)
    cache.put(request, current_value + 1)
    duration = System.monotonic_time() - start
    CarmineGql.Metrics.set_duration_for_counter_cache_put(duration)
    {:noreply, state}
  end

  defp fetch_from_cache(cache, request) do
    case cache.get(request) do
      nil ->
        CarmineGql.Metrics.increment_counter_cache_miss()
        0

      counter ->
        CarmineGql.Metrics.increment_counter_cache_hit()
        counter
    end
  end
end
