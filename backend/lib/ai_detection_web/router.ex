defmodule AIDetectionWeb.Router do
  use Phoenix.Router

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/api", AIDetectionWeb do
    pipe_through :api
  end
end
