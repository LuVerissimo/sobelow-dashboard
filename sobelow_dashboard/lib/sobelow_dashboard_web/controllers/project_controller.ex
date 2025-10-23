defmodule SobelowDashboardWeb.ProjectController do
  use SobelowDashboardWeb, :controller
  alias SobelowDashboard.Scans
  alias SobelowDashboardWeb.ScanJSON

  action_fallback(SobelowDashboardWeb.FallbackController)

  def create(conn, %{"url" => git_url}) do
    name = git_url |> String.split("/") |> Enum.take(-2) |> Enum.join("/")

    with {:ok, project} <- Scans.create_project(%{name: name, git_url: git_url}),
         {:ok, scan} <- Scans.create_scan(%{project_id: project.id, status: "pending"}),
         {:ok, _job} <- Scans.ScanWorker.new(%{scan_id: scan.id}) |> Oban.insert() do
      conn
      |> put_status(:created)
      |> put_view(json: ScanJSON)
      |> render(:show, scan: scan)
    else
      {:error, changeset} ->
        conn
        |> put_status(:unprocessable_entity)
        |> json(%{error: changeset})
    end
  end
end
