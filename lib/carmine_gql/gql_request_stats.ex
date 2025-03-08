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
    {:ok, init_state, {:continue, :setup_cache}}
  end

  @impl true
  def handle_continue(:setup_cache, state) do
    CarmineGql.Caches.DCrdt.setup() 
    {:noreply, state}
  end

  def get_hit_counter(nil), do: 0

  def get_hit_counter(request) when is_binary(request) do
    start = System.monotonic_time()

    result =
      case CarmineGql.Caches.DCrdt.get(request) do
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
    CarmineGql.Caches.DCrdt.put(request, current_value + 1)
    duration = System.monotonic_time() - start
    CarmineGql.Metrics.set_duration_for_counter_cache_put(duration)
    :ok
  end
end
