defmodule AIDetectionWeb.UserSocket do
  use Phoenix.Socket

  channel "detection:*", AIDetectionWeb.DetectionChannel

  def connect(_params, socket, _connect_info) do
    {:ok, socket}
  end

  def id(_socket), do: nil
end
