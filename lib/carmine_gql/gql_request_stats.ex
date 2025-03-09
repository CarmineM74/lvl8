defmodule CarmineGql.GqlRequestStats do
  @storage Application.compile_env(:carmine_gql, :stats_storage)

  @moduledoc """
  Chosen strategy:
    - DeltaCRDT

  Why?
    - We are fine with eventual consistency 
      - we fall in the "dashboard data" use case 
    - We want to have high Availability and Network partition tolerance
      - survivor nodes will serve the data in the event of a network split 
    - Our cluster is small
    - The amount of data to replicate across the cluster is small
  """

  def get_hit_counter(nil), do: 0

  def get_hit_counter(request) when is_binary(request) do
    start = System.monotonic_time()

    result = fetch_from_cache(request)
    duration = System.monotonic_time() - start

    CarmineGql.Metrics.set_duration_for_counter_cache_get(duration)
    result
  end

  def hit(""), do: :ok
  def hit(nil), do: :ok

  def hit(request)
      when is_binary(request) do
    start = System.monotonic_time()
    @storage.hit(request)
    duration = System.monotonic_time() - start
    CarmineGql.Metrics.set_duration_for_counter_cache_put(duration)
  end

  defp fetch_from_cache(request) do
    case @storage.get(request) do
      nil ->
        CarmineGql.Metrics.increment_counter_cache_miss()
        0

      counter ->
        CarmineGql.Metrics.increment_counter_cache_hit()
        counter
    end
  end
end
