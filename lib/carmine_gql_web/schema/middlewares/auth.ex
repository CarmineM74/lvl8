defmodule CarmineGqlWeb.Schema.Middlewares.Auth do
  @behaviour Absinthe.Middleware
  require Logger
  alias CarmineGql.ErrorUtils

  def call(%{context: %{auth_token: token}} = resolution, opts) do
    case Keyword.get(opts, :secret_key) do
      ^token ->
        resolution

      nil ->
        Absinthe.Resolution.put_result(
          resolution,
          {:error,
           ErrorUtils.internal_server_error(
             "could not perform authentication on a protected resource"
           )}
        )

      _wrong_secret ->
        Absinthe.Resolution.put_result(
          resolution,
          {:error,
           ErrorUtils.internal_server_error(
             "could not perform authentication on a protected resource"
           )}
        )
    end
  end

  def call(resolution, _opts) do
    Absinthe.Resolution.put_result(
      resolution,
      {:error, ErrorUtils.internal_server_error("authentication failed")}
    )
  end
end
