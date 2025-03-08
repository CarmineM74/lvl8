defmodule CarmineGql.GqlRequestStats do
  use Agent

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

    Agent.start_link(
      fn ->
        cache.setup()
        %{cache: cache}
      end,
      name: GqlRequestStats
    )
  end

  def get_hit_counter(nil), do: 0

  def get_hit_counter(request) when is_binary(request) do
    cache = Agent.get(GqlRequestStats, fn %{cache: cache} -> cache end)
    start = System.monotonic_time()

    result = fetch_from_cache(cache, request)
    duration = System.monotonic_time() - start

    CarmineGql.Metrics.set_duration_for_counter_cache_get(duration)
    result
  end

  def hit(""), do: :ok
  def hit(nil), do: :ok

  def hit(request)
      when is_binary(request) do
    cache = Agent.get(GqlRequestStats, fn %{cache: cache} -> cache end)
    start = System.monotonic_time()
    cache.hit(request)
    duration = System.monotonic_time() - start
    CarmineGql.Metrics.set_duration_for_counter_cache_put(duration)
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
