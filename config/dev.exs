import Config

# For development, we disable any cache and enable
# debugging and code reloading.
#
# The watchers configuration can be used to run external
# watchers to your application. For example, we can use it
# to bundle .js and .css sources.

port = String.to_integer(System.get_env("PORT") || "4000")

config :carmine_gql, CarmineGqlWeb.Endpoint,
  # Binding to loopback ipv4 address prevents access from other machines.
  # Change to `ip: {0, 0, 0, 0}` to allow access from other machines.
  http: [ip: {127, 0, 0, 1}, port: port],
  check_origin: false,
  code_reloader: true,
  debug_errors: true,
  secret_key_base: "Wd0MinoejcVqTFX2KHcSuCUoaNZj5Fkij1Oo5VhyPi0mfM6YRiw2adIawldnj0/I",
  watchers: []

# Enable dev routes for dashboard and mailbox
config :carmine_gql, dev_routes: true
config :carmine_gql, auth_token_ttl: 20
config :carmine_gql, users_consumer_max_demand: 2

config :logger, :console, format: "$time $metadata[$level] $message\n"

# Set a higher stacktrace during development. Avoid configuring such
# in production as building large stacktraces may be expensive.
config :phoenix, :stacktrace_depth, 20

# Initialize plugs at runtime for faster development compilation
config :phoenix, :plug_init_mode, :runtime
