defmodule CarmineGqlWeb.Schema.Middlewares.Auth do
  @behaviour Absinthe.Middleware
  alias CarmineGql.ErrorUtils

  def call(%{context: %{auth_token: token}} = resolution, opts) do
    case Keyword.get(opts, :secret_key) do
      ^token ->
        resolution

      _wrong_or_nil_token ->
        Absinthe.Resolution.put_result(
          resolution,
          {:error, ErrorUtils.internal_server_error("authentication failed")}
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
