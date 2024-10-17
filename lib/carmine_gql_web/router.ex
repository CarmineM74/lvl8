defmodule CarmineGqlWeb.Router do
  use CarmineGqlWeb, :router

  pipeline :api do
    plug(:accepts, ["json"])
  end

  scope "/" do
    pipe_through(:api)

    forward("/graphql", Absinthe.Plug, schema: CarmineGqlWeb.Schema)

    if Mix.env() === :dev do
      forward("/graphiql", Absinthe.Plug.GraphiQL,
        schema: CarmineGqlWeb.Schema,
        socket: CarmineGqlWeb.UserSocket,
        interface: :playground
      )
    end
  end

  # Enable LiveDashboard in development
  if Application.compile_env(:carmine_gql, :dev_routes) do
    # If you want to use the LiveDashboard in production, you should put
    # it behind authentication and allow only admins to access it.
    # If your application does not have an admins-only section yet,
    # you can use Plug.BasicAuth to set up some basic authentication
    # as long as you are also using SSL (which you should anyway).
    import Phoenix.LiveDashboard.Router

    scope "/dev" do
      pipe_through([:fetch_session, :protect_from_forgery])

      live_dashboard("/dashboard", metrics: CarmineGqlWeb.Telemetry)
    end
  end
end
