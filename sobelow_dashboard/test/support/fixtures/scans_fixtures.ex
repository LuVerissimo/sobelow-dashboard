defmodule SobelowDashboard.ScansFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `SobelowDashboard.Scans` context.
  """

  @doc """
  Generate a project.
  """
  def project_fixture(attrs \\ %{}) do
    {:ok, project} =
      attrs
      |> Enum.into(%{
        git_url: "some git_url",
        name: "some name"
      })
      |> SobelowDashboard.Scans.create_project()

    project
  end

  @doc """
  Generate a finding.
  """
  def finding_fixture(attrs \\ %{}) do
    {:ok, finding} =
      attrs
      |> Enum.into(%{
        confidence: "some confidence",
        description: "some description",
        file: "some file",
        line: 42,
        severity: "some severity",
        vulnerability_type: "some vulnerability_type"
      })
      |> SobelowDashboard.Scans.create_finding()

    finding
  end
end
