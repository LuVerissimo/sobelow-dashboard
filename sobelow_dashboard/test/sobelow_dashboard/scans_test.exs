defmodule SobelowDashboard.ScansTest do
  use SobelowDashboard.DataCase

  alias SobelowDashboard.Scans

  describe "projects" do
    alias SobelowDashboard.Scans.Project

    import SobelowDashboard.ScansFixtures

    @invalid_attrs %{name: nil, git_url: nil}

    test "list_projects/0 returns all projects" do
      project = project_fixture()
      assert Scans.list_projects() == [project]
    end

    test "get_project!/1 returns the project with given id" do
      project = project_fixture()
      assert Scans.get_project!(project.id) == project
    end

    test "create_project/1 with valid data creates a project" do
      valid_attrs = %{name: "some name", git_url: "some git_url"}

      assert {:ok, %Project{} = project} = Scans.create_project(valid_attrs)
      assert project.name == "some name"
      assert project.git_url == "some git_url"
    end

    test "create_project/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Scans.create_project(@invalid_attrs)
    end

    test "update_project/2 with valid data updates the project" do
      project = project_fixture()
      update_attrs = %{name: "some updated name", git_url: "some updated git_url"}

      assert {:ok, %Project{} = project} = Scans.update_project(project, update_attrs)
      assert project.name == "some updated name"
      assert project.git_url == "some updated git_url"
    end

    test "update_project/2 with invalid data returns error changeset" do
      project = project_fixture()
      assert {:error, %Ecto.Changeset{}} = Scans.update_project(project, @invalid_attrs)
      assert project == Scans.get_project!(project.id)
    end

    test "delete_project/1 deletes the project" do
      project = project_fixture()
      assert {:ok, %Project{}} = Scans.delete_project(project)
      assert_raise Ecto.NoResultsError, fn -> Scans.get_project!(project.id) end
    end

    test "change_project/1 returns a project changeset" do
      project = project_fixture()
      assert %Ecto.Changeset{} = Scans.change_project(project)
    end
  end

  describe "findings" do
    alias SobelowDashboard.Scans.Finding

    import SobelowDashboard.ScansFixtures

    @invalid_attrs %{line: nil, file: nil, description: nil, severity: nil, vulnerability_type: nil, confidence: nil}

    test "list_findings/0 returns all findings" do
      finding = finding_fixture()
      assert Scans.list_findings() == [finding]
    end

    test "get_finding!/1 returns the finding with given id" do
      finding = finding_fixture()
      assert Scans.get_finding!(finding.id) == finding
    end

    test "create_finding/1 with valid data creates a finding" do
      valid_attrs = %{line: 42, file: "some file", description: "some description", severity: "some severity", vulnerability_type: "some vulnerability_type", confidence: "some confidence"}

      assert {:ok, %Finding{} = finding} = Scans.create_finding(valid_attrs)
      assert finding.line == 42
      assert finding.file == "some file"
      assert finding.description == "some description"
      assert finding.severity == "some severity"
      assert finding.vulnerability_type == "some vulnerability_type"
      assert finding.confidence == "some confidence"
    end

    test "create_finding/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Scans.create_finding(@invalid_attrs)
    end

    test "update_finding/2 with valid data updates the finding" do
      finding = finding_fixture()
      update_attrs = %{line: 43, file: "some updated file", description: "some updated description", severity: "some updated severity", vulnerability_type: "some updated vulnerability_type", confidence: "some updated confidence"}

      assert {:ok, %Finding{} = finding} = Scans.update_finding(finding, update_attrs)
      assert finding.line == 43
      assert finding.file == "some updated file"
      assert finding.description == "some updated description"
      assert finding.severity == "some updated severity"
      assert finding.vulnerability_type == "some updated vulnerability_type"
      assert finding.confidence == "some updated confidence"
    end

    test "update_finding/2 with invalid data returns error changeset" do
      finding = finding_fixture()
      assert {:error, %Ecto.Changeset{}} = Scans.update_finding(finding, @invalid_attrs)
      assert finding == Scans.get_finding!(finding.id)
    end

    test "delete_finding/1 deletes the finding" do
      finding = finding_fixture()
      assert {:ok, %Finding{}} = Scans.delete_finding(finding)
      assert_raise Ecto.NoResultsError, fn -> Scans.get_finding!(finding.id) end
    end

    test "change_finding/1 returns a finding changeset" do
      finding = finding_fixture()
      assert %Ecto.Changeset{} = Scans.change_finding(finding)
    end
  end
end
