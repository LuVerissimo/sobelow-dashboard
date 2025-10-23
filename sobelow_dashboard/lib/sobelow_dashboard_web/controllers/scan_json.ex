defmodule SobelowDashboardWeb.ScanJSON do
  alias SobelowDashboard.Scans.Scan

  def show(%{scan: scan}) do
    %{data: data(scan)}
  end

  defp data(%Scan{} = scan) do
    %{
      id: scan.id,
      status: scan.status
    }
  end
end
