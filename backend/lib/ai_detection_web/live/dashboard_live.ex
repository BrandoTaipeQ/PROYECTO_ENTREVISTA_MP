defmodule AIDetectionWeb.DashboardLive do
  use Phoenix.LiveView

  def mount(_params, _session, socket) do
    {:ok, assign(socket, score: 0, alerts: [], candidate_status: "Analizando...")}
  end

  def render(assigns) do
    ~H"""
    <div class="dashboard-container p-6 bg-slate-900 text-white min-h-screen">
      <header class="flex justify-between items-center border-b border-slate-700 pb-4 mb-6">
        <h1 class="text-2xl font-bold text-blue-400">AI Detection System</h1>
        <div class="status flex items-center">
          <span class="w-3 h-3 bg-green-500 rounded-full mr-2"></span>
          <span>Sessión en Vivo: Google Meet</span>
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

      <div class="mt-8 bg-slate-800 p-6 rounded-xl border border-slate-700 shadow-lg">
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
    """
  end
end
