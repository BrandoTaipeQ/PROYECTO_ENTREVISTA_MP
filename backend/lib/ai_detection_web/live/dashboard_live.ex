defmodule AIDetectionWeb.DashboardLive do
  use Phoenix.LiveView

  alias AIDetection.Bot.Manager

  def mount(_params, _session, socket) do
    if connected?(socket) do
      Phoenix.PubSub.subscribe(AIDetection.PubSub, "bots")
    end

    {:ok, assign(socket,
      score: 0,
      alerts: [],
      candidate_status: "Analizando...",
      meeting_url: "",
      bots: Manager.list_bots()
    )}
  end

  def handle_event("spawn_bot", %{"meeting_url" => url}, socket) do
    Manager.spawn_bot(url)
    {:noreply, assign(socket, meeting_url: "")}
  end

  def handle_info({:bot_updated, bot}, socket) do
    bots = [bot | Enum.reject(socket.assigns.bots, &(&1.id == bot.id))]
    {:noreply, assign(socket, bots: bots)}
  end

  def handle_info({:bot_removed, bot_id}, socket) do
    bots = Enum.reject(socket.assigns.bots, &(&1.id == bot_id))
    {:noreply, assign(socket, bots: bots)}
  end

  def render(assigns) do
    ~H"""
    <div class="dashboard-container p-6 bg-slate-900 text-white min-h-screen">
      <header class="flex justify-between items-center border-b border-slate-700 pb-4 mb-6">
        <h1 class="text-2xl font-bold text-blue-400">AI Detection System</h1>
        <div class="flex items-center gap-4">
          <form phx-submit="spawn_bot" class="flex gap-2">
            <input type="text" name="meeting_url" placeholder="Google Meet URL" class="bg-slate-800 border border-slate-700 rounded px-3 py-1 text-sm focus:outline-none focus:border-blue-500" required />
            <button type="submit" class="bg-blue-600 hover:bg-blue-700 px-4 py-1 rounded text-sm font-bold transition">Invitar Bot</button>
          </form>
          <div class="status flex items-center">
            <span class="w-3 h-3 bg-green-500 rounded-full mr-2"></span>
            <span>Sistema Activo</span>
          </div>
        </div>
      </header>

      <div class="grid grid-cols-1 md:grid-cols-3 gap-6">
        <div class="card bg-slate-800 p-6 rounded-xl border border-slate-700 shadow-lg">
          <h3 class="text-slate-400 uppercase text-xs font-semibold mb-2">Probabilidad de IA</h3>
          <div class="text-5xl font-black text-red-500">{@score}%</div>
          <div class="mt-4 bg-slate-700 h-2 rounded-full overflow-hidden">
            <div class="bg-red-500 h-full" style={"width: #{@score}%"}></div>
          </div>
        </div>

        <div class="card bg-slate-800 p-6 rounded-xl border border-slate-700 shadow-lg md:col-span-2">
          <h3 class="text-slate-400 uppercase text-xs font-semibold mb-4">Alertas en Tiempo Real</h3>
          <div class="space-y-3">
            <%= for alert <- @alerts do %>
              <div class="alert-item flex items-start p-3 bg-slate-700 rounded-lg border-l-4 border-red-500">
                <span class="text-sm font-medium"><%= alert %></span>
              </div>
            <% end %>
            <%= if Enum.empty?(@alerts) do %>
              <p class="text-slate-500 italic text-sm">No se han detectado anomalías hasta ahora.</p>
            <% end %>
          </div>
        </div>
      </div>

      <div class="grid grid-cols-1 md:grid-cols-2 gap-6 mt-8">
        <div class="bg-slate-800 p-6 rounded-xl border border-slate-700 shadow-lg">
          <h3 class="text-slate-400 uppercase text-xs font-semibold mb-4">Bots Activos</h3>
          <div class="space-y-3">
            <%= for bot <- @bots do %>
              <div class="flex justify-between items-center p-3 bg-slate-700 rounded-lg">
                <div>
                  <div class="text-sm font-bold text-blue-300">Bot <%= String.slice(bot.id, 0..7) %></div>
                  <div class="text-xs text-slate-400 truncate max-w-xs"><%= bot.url %></div>
                </div>
                <div class="text-right">
                  <span class="text-xs px-2 py-1 bg-green-900 text-green-300 rounded"><%= bot.status %></span>
                  <div class="text-[10px] text-slate-500 mt-1"><%= bot.started_at |> DateTime.to_time() %></div>
                </div>
              </div>
            <% end %>
            <%= if Enum.empty?(@bots) do %>
              <p class="text-slate-500 italic text-sm text-center">No hay bots activos en este momento.</p>
            <% end %>
          </div>
        </div>

        <div class="bg-slate-800 p-6 rounded-xl border border-slate-700 shadow-lg">
          <h3 class="text-slate-400 uppercase text-xs font-semibold mb-4">Métricas de Comportamiento</h3>
        <div class="grid grid-cols-2 md:grid-cols-4 gap-4 text-center">
          <div>
            <div class="text-xl font-bold">1.2s</div>
            <div class="text-xs text-slate-500">TTFR (Promedio)</div>
          </div>
          <div>
            <div class="text-xl font-bold text-yellow-400">Inestable</div>
            <div class="text-xs text-slate-500">Patrón Ocular</div>
          </div>
          <div>
            <div class="text-xl font-bold text-green-400">Humana</div>
            <div class="text-xs text-slate-500">Firma de Voz</div>
          </div>
          <div>
            <div class="text-xl font-bold">Limpia</div>
            <div class="text-xs text-slate-500">Red (Jitter)</div>
          </div>
        </div>
        </div>
      </div>
    </div>
    """
  end
end
