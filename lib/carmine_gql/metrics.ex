defmodule CarmineGql.Metrics do
  import Telemetry.Metrics, only: [last_value: 2, counter: 2, distribution: 2]

  def metrics() do
    [
      PrometheusTelemetry.Metrics.Ecto.metrics(:carmine_gql),
      PrometheusTelemetry.Metrics.GraphQL.metrics(),
      PrometheusTelemetry.Metrics.Phoenix.metrics(),
      PrometheusTelemetry.Metrics.VM.metrics()
    ]
  end
end
