defmodule CarmineGql.Metrics do
  import Telemetry.Metrics, only: [last_value: 2, counter: 2, distribution: 2]

  @event_prefix [:carmine_gql]

  def metrics() do
    [
      PrometheusTelemetry.Metrics.Ecto.metrics_for_repo(CarmineGql.Repo),
      PrometheusTelemetry.Metrics.GraphQL.metrics(),
      PrometheusTelemetry.Metrics.Phoenix.metrics(),
      PrometheusTelemetry.Metrics.VM.metrics(),
      counter(
        "carmine_gql.auth_tokens_generated.count",
        event_name: @event_prefix ++ [:auth_tokens_generated],
        measurement: :count,
        description: "Number of auth tokens that have been generated"
      ),
      distribution(
        "carmine_gql.auth_tokens_generation.duration.milliseconds",
        event_name: @event_prefix ++ [:auth_tokens_generation],
        measurement: :duration,
        unit: {:native, :millisecond},
        reporter_options: [
          buckets: [50, 100, 200, 500]
        ]
      ),
      counter(
        "carmine_gql.counter_cache_hits.count",
        event_name: @event_prefix ++ [:counter_cache_hits],
        measurement: :count,
        description: "Counters cache hits"
      ),
      counter(
        "carmine_gql.counter_cache_misses.count",
        event_name: @event_prefix ++ [:counter_cache_misses],
        measurement: :count,
        description: "Counters cache misses"
      ),
      distribution(
        "carmine_gql.counter_cache_get.duration.milliseconds",
        event_name: @event_prefix ++ [:counter_cache_get],
        measurement: :duration,
        unit: {:native, :millisecond},
        reporter_options: [
          buckets: [50, 100, 200, 500]
        ]
      ),
      distribution(
        "carmine_gql.counter_cache_put.duration.milliseconds",
        event_name: @event_prefix ++ [:counter_cache_put],
        measurement: :duration,
        unit: {:native, :millisecond},
        reporter_options: [
          buckets: [50, 100, 200, 500]
        ]
      )
    ]
  end

  def increment_auth_tokens_generated() do
    :telemetry.execute(@event_prefix ++ [:auth_tokens_generated], %{count: 1})
  end

  def set_duration_for_auth_token_generation(duration) do
    :telemetry.execute(@event_prefix ++ [:auth_tokens_generation], %{duration: duration})
  end

  def increment_counter_cache_hit() do
    :telemetry.execute(@event_prefix ++ [:counter_cache_hits], %{count: 1})
  end

  def increment_counter_cache_miss() do
    :telemetry.execute(@event_prefix ++ [:counter_cache_misses], %{count: 1})
  end

  def set_duration_for_counter_cache_get(duration) do
    :telemetry.execute(@event_prefix ++ [:counter_cache_get], %{duration: duration})
  end

  def set_duration_for_counter_cache_put(duration) do
    :telemetry.execute(@event_prefix ++ [:counter_cache_put], %{duration: duration})
  end
end
