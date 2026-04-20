import Config

config :ai_detection, AIDetectionWeb.Endpoint,
  http: [port: 4000],
  pubsub_server: AIDetection.PubSub

config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

config :phoenix, :json_library, Jason
