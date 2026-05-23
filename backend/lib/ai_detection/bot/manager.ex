defmodule AIDetection.Bot.Manager do
  use GenServer
  require Logger

  def start_link(_) do
    GenServer.start_link(__MODULE__, %{}, name: __MODULE__)
  end

  def spawn_bot(meeting_url) do
    GenServer.call(__MODULE__, {:spawn_bot, meeting_url})
  end

  def init(state) do
    {:ok, state}
  end

  def handle_call({:spawn_bot, meeting_url}, _from, state) do
    Logger.info("Spawning bot for meeting: #{meeting_url}")
    # In a real scenario, this would use a library like Playwright or Puppeteer
    # to open a headless browser and join Google Meet.
    bot_id = Ecto.UUID.generate()
    {:reply, {:ok, bot_id}, Map.put(state, bot_id, meeting_url)}
  end
end
