defmodule CarmineGqlWeb.UserSocket do
  use Phoenix.Socket
  use Absinthe.Phoenix.Socket, schema: CarmineGqlWeb.Schema

  @impl true
  def connect(params, socket, _connect_info) do
    socket = maybe_put_authenticate(socket, params)

    {:ok, socket}
  end

  defp maybe_put_authenticate(socket, params) do
    if Map.get(params, "auth_token") do
      Absinthe.Phoenix.Socket.put_options(socket, context: %{auth_token: params["auth_token"]})
    else
      socket
    end
  end

  @impl true
  def id(_socket), do: nil
end
