defmodule CarmineGql.Application do
  use Application

  @impl true
  def start(_type, _args) do
    children = supervised_children(Mix.env())
    opts = [strategy: :one_for_one, name: CarmineGql.Supervisor]
    Supervisor.start_link(children, opts)
  end

  defp supervised_children(:common) do
    telemetry_port = String.to_integer(System.get_env("TELEMETRY_PORT") || "4050")

    [
      CarmineGqlWeb.Telemetry,
      {DNSCluster, query: Application.get_env(:carmine_gql, :dns_cluster_query) || :ignore},
      {Phoenix.PubSub, name: CarmineGql.PubSub},
      CarmineGql.Repo,
      CarmineGqlWeb.Endpoint,
      {Absinthe.Subscription, CarmineGqlWeb.Endpoint},
      {PrometheusTelemetry,
       exporter: [enabled?: true, opts: [port: telemetry_port]],
       metrics: CarmineGql.Metrics.metrics()}
    ]
  end

  defp supervised_children(:test),
    do: supervised_children(:common)

  defp supervised_children(_other) do
    topologies = Application.get_env(:libcluster, :topologies)

    supervised_children(:common) ++
      [
        {Cluster.Supervisor, [topologies, [name: CarmineGql.ClusterSupervisor]]},
        CarmineGql.RedisCache,
        CarmineGql.GqlRequestStats,
        CarmineGql.AuthTokenCache,
        CarmineGql.AuthTokensPipeline.UsersProducer,
        CarmineGql.AuthTokensPipeline.UsersConsumerSupervisor
      ]
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    CarmineGqlWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
