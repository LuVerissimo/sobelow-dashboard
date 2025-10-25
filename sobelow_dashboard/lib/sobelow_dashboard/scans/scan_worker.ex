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
    scan = Scans.get_scan_and_preload_project!(scan_id)
    project = scan.project

    tmp_path = Path.join(System.tmp_dir!(), "scan-#{scan.id}")
    File.mkdir_p!(tmp_path)

    try do
      # --- Disable any git credential helper or prompt logic ---
      git_env = [
        {"GIT_TERMINAL_PROMPT", "0"},
        {"GIT_ASKPASS", ""},
        {"GH_TOKEN", ""},
        {"GITHUB_TOKEN", ""},
        {"TERM", "dumb"} # disable ANSI colors
      ]

      git_args = [
        "-c",
        "credential.helper=",
        "-c",
        "credential.useHttpPath=false",
        "-c",
        "credential.interactive=never",
        "-c",
        "credential.credentialStore=",
        "clone",
        "--depth",
        "1",
        project.git_url,
        tmp_path
      ]

      IO.puts("Cloning #{project.git_url} into #{tmp_path}...")

      case System.cmd("git", git_args, stderr_to_stdout: true, env: git_env) do
        {output, 0} ->
          IO.puts("✅ Git clone succeeded.")
          sobelow_path = tmp_path
          IO.puts("Running Sobelow on #{sobelow_path}...")

          {json_output, exit_code} =
            System.cmd("sobelow", ["--format", "json", "--path", sobelow_path])

          if exit_code in [0, 1] do
            parse_and_save_findings(scan, json_output)
            Scans.update_scan(scan, %{status: "complete"})
          else
            IO.puts("Sobelow returned non-zero exit code: #{exit_code}")
            Scans.update_scan(scan, %{status: "something went wrong"})
          end

        {output, _exit_code} ->
          IO.puts("❌ Git clone failed:\n#{output}")

          status =
            if String.contains?(output, "Authentication failed") do
              "authentication failed or repo is private"
            else
              "failed to clone repo"
            end

          Scans.update_scan(scan, %{status: status})
      end
    rescue
      e ->
        IO.puts("❌ Exception: #{inspect(e)}")
        IO.puts(Exception.format(:error, e, __STACKTRACE__))
        Scans.update_scan(scan, %{status: "failed"})
        reraise e, __STACKTRACE__
    after
      File.rm_rf!(tmp_path)
    end

    :ok
  end

  defp parse_and_save_findings(scan, json_output) do
    with {:ok, findings_json} <- Jason.decode(json_output) do
      now = DateTime.utc_now() |> DateTime.truncate(:second)

      findings =
        findings_json["findings"]
        |> Enum.flat_map(fn
          {confidence_level, list} when is_list(list) ->
            Enum.map(list, fn finding ->
              %{
                scan_id: scan.id,
                vulnerability_type: finding["type"] || finding["vulnerability_type"],
                file: finding["file"],
                line: finding["line"],
                confidence: confidence_level,
                severity: finding["severity"] || "unknown",
                description: finding["type"] || finding["description"] || "",
                inserted_at: now,
                updated_at: now
              }
            end)

          _ ->
            []
        end)

      Scans.create_findings(findings)
    end
  end
end
