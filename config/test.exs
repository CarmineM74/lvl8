import Config

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :carmine_gql, CarmineGqlWeb.Endpoint,
  http: [ip: {127, 0, 0, 1}, port: 4002],
  secret_key_base: "uOlm5yjeUqy4jhJXGxUuUic67LChpEVGzQayPFsAWFeKzjZPIQ4CCq5e6yVvYxtT",
  server: false

# Print only warnings and errors during test
config :logger, level: :warning

# Initialize plugs at runtime for faster test compilation
config :phoenix, :plug_init_mode, :runtime

config :carmine_gql, CarmineGql.Repo,
  database: "carmine_gql_test",
  username: "postgres",
  password: "postgres",
  hostname: "localhost",
  pool: Ecto.Adapters.SQL.Sandbox
