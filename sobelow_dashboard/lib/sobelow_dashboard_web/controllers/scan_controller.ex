defmodule SobelowDashboardWeb.ScanController do
  use SobelowDashboardWeb, :controller
  alias SobelowDashboard.Scans
  alias SobelowDashboardWeb.ScanJSON
  alias SobelowDashboardWeb.FindingsJSON
  require Logger
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
        where: j.queue == "default",
        where: j.state in ["available", "scheduled", "retryable", "executing"],
        where: fragment("?->>'scan_id' = ?", j.args, ^Integer.to_string(int_scan_id))
      )

    # Cancel every job found
    case Oban.cancel_all_jobs(query) do
      {:ok, _count} ->
        case Scans.get_scan(scan_id) do
          {:ok, scan} ->
            case Scans.update_scan(scan, %{status: "failed"}) do
              {:ok, _updated_scan} ->
                send_resp(conn, :no_content, "")

              {:error, _changeset} ->
                # Failed to update DB
                conn
                |> put_status(:internal_server_error)
                |> json(%{error: "Failed to update scan status"})
            end

          {:error, _reason} ->
            # Scan doesn't exist but canceling works.
            send_resp(conn, :no_content, "")
        end

      {:error, reason} ->
        Logger.error("failed to cancel jobs for scan #{scan_id}: #{inspect(reason)}")
        conn |> put_status(:internal_server_error) |> json(%{error: "Failed to cancel Oban job"})
    end
  end
end
