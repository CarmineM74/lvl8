# This file is responsible for configuring your application
# and its dependencies with the aid of the Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
import Config

config :carmine_gql, CarmineGql.Repo,
  database: "carmine_gql",
  username: "postgres",
  password: "postgres",
  hostname: "localhost"

config :carmine_gql, ecto_repos: [CarmineGql.Repo]

config :ecto_shorts,
  repo: CarmineGql.Repo,
  error_module: EctoShorts.Actions.Error

config :carmine_gql,
  generators: [timestamp_type: :utc_datetime]

# Configures the endpoint
config :carmine_gql, CarmineGqlWeb.Endpoint,
  url: [host: "localhost"],
  adapter: Bandit.PhoenixAdapter,
  render_errors: [
    formats: [json: CarmineGqlWeb.ErrorJSON],
    layout: false
  ],
  pubsub_server: CarmineGql.PubSub,
  live_view: [signing_salt: "6aB4g5gL"]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# LibCluster configuration
config :libcluster,
  topologies: [
    epmd: [
      strategy: Cluster.Strategy.Epmd,
      config: [
        hosts: [:node_a@localhost, :node_b@localhost]
      ]
    ]
  ]

config :request_cache_plug,
  enabled?: true,
  verbose?: true,
  cached_errors: :all,
  request_cache_module: CarmineGql.RedisCache,
  default_ttl: :timer.seconds(10)

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{config_env()}.exs"
