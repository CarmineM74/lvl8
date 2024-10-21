defmodule CarmineGqlWeb.SubscriptionCase do
  use ExUnit.CaseTemplate

  using do
    quote do
      use CarmineGqlWeb.ChannelCase

      use Absinthe.Phoenix.SubscriptionTest,
        schema: CarmineGqlWeb.Schema

      setup do
        {:ok, socket} =
          Phoenix.ChannelTest.connect(CarmineGqlWeb.UserSocket, %{})

        {:ok, socket} = Absinthe.Phoenix.SubscriptionTest.join_absinthe(socket)
        {:ok, %{socket: socket}}
      end
    end
  end
end
