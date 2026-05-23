defmodule AIDetection.Interviews.ReportGenerator do
  require Logger

  def generate_json_report(interview_id, results) do
    report = %{
      interview_id: interview_id,
      timestamp: DateTime.utc_now(),
      final_score: results.score,
      summary: results.summary,
      alerts: results.alerts
    }
    Jason.encode!(report)
  end

  def export_to_file(interview_id, results) do
    content = generate_json_report(interview_id, results)
    filename = "report_#{interview_id}.json"
    File.write!(filename, content)
    {:ok, filename}
  end
end
