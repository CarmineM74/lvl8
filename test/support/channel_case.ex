defmodule CarmineGqlWeb.ChannelCase do
  use ExUnit.CaseTemplate

  using do
    quote do
      import Phoenix.ChannelTest
      @endpoint CarmineGqlWeb.Endpoint
    end
  end
end
