defmodule SobelowDashboardWeb.FindingsJSON do
  alias SobelowDashboard.Scans.Finding

  def findings(%{findings: findings}) do
    %{data: for(finding <- findings, do: data(finding))}
  end

  defp data(%Finding{} = finding) do
    %{
      vulnerability_type: finding.vulnerability_type,
      file: finding.file,
      line: finding.line,
      confidence: finding.confidence,
      severity: finding.severity,
      description: finding.description,
      scan_id: finding.scan_id
    }
  end
end
