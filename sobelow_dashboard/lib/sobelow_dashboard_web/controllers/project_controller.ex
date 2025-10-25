defmodule SobelowDashboardWeb.ProjectController do
  use SobelowDashboardWeb, :controller
  alias SobelowDashboard.Scans
  alias SobelowDashboardWeb.ScanJSON

  action_fallback(SobelowDashboardWeb.FallbackController)

  # --- regex for GitHub HTTPS URLs ---
  @github_regex ~r/^https:\/\/github\.com\/[\w\-.]+\/[\w\-.]+(\.git)?$/i

  def create(conn, %{"url" => git_url}) do
    # validation
    case Regex.match?(@github_regex, git_url) do
      true ->
        name = git_url |> String.split("/") |> Enum.take(-2) |> Enum.join("/")

        with {:ok, project} <- Scans.create_project(%{name: name, git_url: git_url}),
             {:ok, scan} <- Scans.create_scan(%{project_id: project.id, status: "pending"}),
             {:ok, _job} <- Scans.ScanWorker.new(%{scan_id: scan.id}) |> Oban.insert() do
          conn
          |> put_status(:created)
          |> put_view(json: ScanJSON)
          |> render(:show, scan: scan)
        end

      false ->
        conn
        |> put_status(:unprocessable_entity)
        |> put_view(json: SobelowDashboardWeb.ChangesetJSON)
        |> render(:error,
          changeset: %Ecto.Changeset{errors: [git_url: {"is not a valid GitHub HTTPS URL", []}]}
        )
    end
  end
end
