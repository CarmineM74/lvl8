defmodule CarmineGqlWeb.AuthPlug do
  @behaviour Plug

  import Plug.Conn

  @impl Plug
  def init(defaults), do: defaults

  @impl Plug
  def call(conn, _defaults) do
    case fetch_auth_token(conn) do
      {:error, _} ->
        conn

      {:ok, token} ->
        Absinthe.Plug.put_options(conn, context: %{auth_token: token})
    end
  end

  defp fetch_auth_token(conn) do
    case get_req_header(conn, "authorization") do
      ["Bearer " <> token] ->
        {:ok, token}

      _ ->
        {:error, :no_auth_token}
    end
  end
end
