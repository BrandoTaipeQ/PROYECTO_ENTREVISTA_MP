defmodule AIDetection.Bot.Manager do
  use GenServer
  require Logger

  def start_link(_) do
    GenServer.start_link(__MODULE__, %{}, name: __MODULE__)
  end

  def spawn_bot(meeting_url) do
    GenServer.call(__MODULE__, {:spawn_bot, meeting_url})
  end

  def list_bots do
    GenServer.call(__MODULE__, :list_bots)
  end

  def init(state) do
    {:ok, state}
  end

  def handle_call({:spawn_bot, meeting_url}, _from, state) do
    bot_id = :crypto.strong_rand_bytes(8) |> Base.encode16()
    Logger.info("Spawning bot #{bot_id} for meeting: #{meeting_url}")

    # Start the bot process asynchronously
    Task.start(fn ->
      run_bot_process(bot_id, meeting_url)
    end)

    new_bot = %{
      id: bot_id,
      url: meeting_url,
      status: "Starting",
      started_at: DateTime.utc_now()
    }

    new_state = Map.put(state, bot_id, new_bot)
    broadcast_update(new_bot)

    {:reply, {:ok, bot_id}, new_state}
  end

  def handle_call(:list_bots, _from, state) do
    {:reply, Map.values(state), state}
  end

  def handle_info({:bot_exit, bot_id, exit_status}, state) do
    Logger.info("Bot #{bot_id} exited with status: #{inspect(exit_status)}")
    new_state = Map.delete(state, bot_id)
    Phoenix.PubSub.broadcast(AIDetection.PubSub, "bots", {:bot_removed, bot_id})
    {:noreply, new_state}
  end

  defp run_bot_process(bot_id, meeting_url) do
    python_path = "python3" # Or absolute path if needed
    script_path = Path.join(:code.priv_dir(:ai_detection), "bot/meet_bot.py")

    case System.cmd(python_path, [script_path, meeting_url], stderr_to_stdout: true) do
      {output, status} ->
        Logger.info("Bot #{bot_id} output: #{output}")
        send(__MODULE__, {:bot_exit, bot_id, status})
    end
  end

  defp broadcast_update(bot) do
    Phoenix.PubSub.broadcast(AIDetection.PubSub, "bots", {:bot_updated, bot})
  end
end
