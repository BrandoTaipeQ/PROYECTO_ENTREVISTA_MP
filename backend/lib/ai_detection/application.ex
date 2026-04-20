defmodule AIDetection.Application do
  use Application

  def start(_type, _args) do
    children = [
      # Start the telemetry supervisor
      # Start the PubSub system
      {Phoenix.PubSub, name: AIDetection.PubSub},
      # Start the endpoint when the application starts
      AIDetectionWeb.Endpoint
    ]

    opts = [strategy: :one_for_one, name: AIDetection.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
