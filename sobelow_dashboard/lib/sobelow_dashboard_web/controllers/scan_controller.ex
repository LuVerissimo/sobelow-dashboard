defmodule SobelowDashboardWeb.ScanController do
  use SobelowDashboardWeb, :controller
  alias SobelowDashboard.Scans
  alias SobelowDashboardWeb.ScanJSON
  alias SobelowDashboardWeb.FindingsJSON

  import Ecto.Query

  def show(conn, %{"id" => id}) do
    scan = Scans.get_scan!(id)

    conn
    |> put_view(json: ScanJSON)
    |> render(:show, scan: scan)
  end

  def findings(conn, %{"id" => id}) do
    findings = Scans.list_findings_for_scan(id, conn.params)

    conn
    |> put_view(json: FindingsJSON)
    |> render(:findings, findings: findings)
  end

  def cancel(conn, %{"id" => scan_id}) do
    int_scan_id = String.to_integer(scan_id)

    # Find all matching jobs not in a final state
    query =
    from(j in Oban.Job,
      where: j.queue == :default,
      where: j.state in [:available, :scheduled, :retryable, :executing],
      where: fragment("?->>'scan_id' = ?", j.args, ^Integer.to_string(int_scan_id)) # Query JSONB
    )

    # Cancel every job found
    Oban.cancel_all_jobs(query)

    # Set scan status to 'failed'
    with {:ok, scan} <- Scans.get_scan(scan_id) do
      Scans.update_scan(scan, %{status: "failed"})
    end

    send_resp(conn, :no_content, "")
  end
end
