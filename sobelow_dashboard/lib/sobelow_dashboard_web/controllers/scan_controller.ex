defmodule SobelowDashboardWeb.ScanController do
  use SobelowDashboardWeb, :controller
  alias SobelowDashboard.Scans
  alias SobelowDashboardWeb.ScanJSON
  alias SobelowDashboardWeb.FindingsJSON

  def show(conn, %{"id" => id}) do
    scan = Scans.get_scan!(id)

    conn
    |> put_view(json: ScanJSON)
    |> render(:show, scan: scan)
  end

  def findings(conn, %{"id" => id}) do
    findings = Scans.list_findings_for_scan(id)

    conn
    |> put_view(json: FindingsJSON)
    |> render(:findings, findings: findings)
  end
end
