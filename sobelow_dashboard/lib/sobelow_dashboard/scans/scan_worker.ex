defmodule SobelowDashboard.Scans.ScanWorker do
  use Oban.Worker, queue: :default, max_attempts: 3

  alias SobelowDashboard.Scans

  @impl Oban.Worker
  def timeout(%Oban.Job{args: %{"scan_id" => _scan_id}}), do: :timer.minutes(5)

  def discard(%Oban.Job{args: %{"scan_id" => scan_id}, state: "discarded"}) do
    # Run when job fails max_attempts
    with {:ok, scan} <- Scans.get_scan(scan_id) do
      Scans.update_scan(scan, %{status: "failed"})
    end
  end

  @impl Oban.Worker
  def perform(%Oban.Job{args: %{"scan_id" => scan_id}}) do
    # get data / update status
    scan = Scans.get_scan!(scan_id) |> Scans.update_scan(%{status: "running"})

    project = Scans.get_project!(scan.project_id)

    tmp_path = Path.join(System.tmp_dir!(), "scan-#{scan.id}")
    File.mkdir_p!(tmp_path)

    try do
      # clone repo
      case System.cmd("git", ["clone", "--depth", "1", project.git_url, tmp_path]) do
        {_, 0} ->
          sobelow_path = tmp_path

          {json_output, exit_code} =
            System.cmd("sobelow", ["--format", "json", "--path", sobelow_path])

          if exit_code in [0, 1] do
            parse_and_save_findings(scan, json_output)
            Scans.update_scan(scan, %{status: "complete"})
          else
            Scans.update_scan(scan, %{status: "something went wrong"})
          end

        _ ->
          # cloning failed
          Scans.update_scan(scan, %{status: "failed to clone repo"})
      end
    rescue
      e ->
        Scans.update_scan(scan, %{status: "failed"})
        reraise e, __STACKTRACE__
    after
      File.rm_rf!(tmp_path)
    end

    :ok
  end

  defp parse_and_save_findings(scan, json_output) do
    with {:ok, findings_json} <- Jason.decode(json_output) do
      findings =
        findings_json["findings"]
        |> Enum.map(fn finding ->
          %{
            scan_id: scan.id,
            vulnerability_type: finding["vulnerability_type"],
            file: finding["file"],
            line: finding["line"],
            confidence: finding["confidence"],
            severity: finding["severity"],
            description: finding["description"]
          }
        end)

      Scans.create_findings(findings)
    end
  end
end
