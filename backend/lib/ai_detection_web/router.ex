defmodule AIDetectionWeb.Router do
  use Phoenix.Router

  pipeline :api do
    plug :accepts, ["json"]
  end

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, {AIDetectionWeb.LayoutView, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  scope "/", AIDetectionWeb do
    pipe_through :browser

    live "/dashboard", DashboardLive
  end

  scope "/api", AIDetectionWeb do
    pipe_through :api
  end
end
