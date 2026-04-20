defmodule AIDetectionWeb.DetectionChannel do
  use Phoenix.Channel

  def join("detection:lobby", _payload, socket) do
    {:ok, socket}
  end

  def handle_in("telemetry", payload, socket) do
    # Here we would process the signal or forward to the inference engines
    # For now, we just log it and echo back
    IO.inspect(payload, label: "Received Telemetry")
    broadcast!(socket, "alert", %{message: "Suspicious activity detected", score: payload["confidence"]})
    {:noreply, socket}
  end
end
