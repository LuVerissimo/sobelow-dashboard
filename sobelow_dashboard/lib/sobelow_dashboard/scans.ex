defmodule SobelowDashboard.Scans do
  @moduledoc """
  The Scans context.
  """

  import Ecto.Query, warn: false
  alias SobelowDashboard.Repo

  alias SobelowDashboard.Scans.Project

  @doc """
  Returns the list of projects.

  ## Examples

      iex> list_projects()
      [%Project{}, ...]

  """
  def list_projects do
    Repo.all(Project)
  end

  @doc """
  Gets a single project.

  Raises `Ecto.NoResultsError` if the Project does not exist.

  ## Examples

      iex> get_project!(123)
      %Project{}

      iex> get_project!(456)
      ** (Ecto.NoResultsError)

  """
  def get_project!(id), do: Repo.get!(Project, id)

  @doc """
  Creates a project.

  ## Examples

      iex> create_project(%{field: value})
      {:ok, %Project{}}

      iex> create_project(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_project(attrs) do
    %Project{}
    |> Project.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a project.

  ## Examples

      iex> update_project(project, %{field: new_value})
      {:ok, %Project{}}

      iex> update_project(project, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_project(%Project{} = project, attrs) do
    project
    |> Project.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a project.

  ## Examples

      iex> delete_project(project)
      {:ok, %Project{}}

      iex> delete_project(project)
      {:error, %Ecto.Changeset{}}

  """
  def delete_project(%Project{} = project) do
    Repo.delete(project)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking project changes.

  ## Examples

      iex> change_project(project)
      %Ecto.Changeset{data: %Project{}}

  """
  def change_project(%Project{} = project, attrs \\ %{}) do
    Project.changeset(project, attrs)
  end

  alias SobelowDashboard.Scans.Finding

  @doc """
  Returns the list of findings.

  ## Examples

      iex> list_findings()
      [%Finding{}, ...]

  """
  def list_findings do
    Repo.all(Finding)
  end

  @doc """
  Gets a single finding.

  Raises `Ecto.NoResultsError` if the Finding does not exist.

  ## Examples

      iex> get_finding!(123)
      %Finding{}

      iex> get_finding!(456)
      ** (Ecto.NoResultsError)

  """
  def get_finding!(id), do: Repo.get!(Finding, id)

  @doc """
  Creates a finding.

  ## Examples

      iex> create_finding(%{field: value})
      {:ok, %Finding{}}

      iex> create_finding(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_finding(attrs) do
    %Finding{}
    |> Finding.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a finding.

  ## Examples

      iex> update_finding(finding, %{field: new_value})
      {:ok, %Finding{}}

      iex> update_finding(finding, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_finding(%Finding{} = finding, attrs) do
    finding
    |> Finding.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a finding.

  ## Examples

      iex> delete_finding(finding)
      {:ok, %Finding{}}

      iex> delete_finding(finding)
      {:error, %Ecto.Changeset{}}

  """
  def delete_finding(%Finding{} = finding) do
    Repo.delete(finding)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking finding changes.

  ## Examples

      iex> change_finding(finding)
      %Ecto.Changeset{data: %Finding{}}

  """
  def change_finding(%Finding{} = finding, attrs \\ %{}) do
    Finding.changeset(finding, attrs)
  end

  alias SobelowDashboard.Scans.Scan

  @doc """
  Returns the list of scans.

  ## Examples

      iex> list_scans()
      [%Scan{}, ...]

  """
  def list_scans do
    Repo.all(Scan)
  end

  @doc """
  Gets a single scan.

  Raises `Ecto.NoResultsError` if the Scan does not exist.

  ## Examples

      iex> get_scan!(123)
      %Scan{}

      iex> get_scan!(456)
      ** (Ecto.NoResultsError)

  """
  def get_scan!(id), do: Repo.get!(Scan, id)

  def get_scan(id) do
    case Repo.get(Scan, id) do
      nil -> {:error, :not_found}
      scan -> {:ok, scan}
    end
  end

  def get_scan_and_preload_project!(id) do
    Repo.get!(Scan, id)
    |> Repo.preload(:project)
  end

  @doc """
  Creates a scan.

  ## Examples

      iex> create_scan(%{field: value})
      {:ok, %Scan{}}

      iex> create_scan(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_scan(attrs) do
    %Scan{}
    |> Scan.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a scan.

  ## Examples

      iex> update_scan(scan, %{field: new_value})
      {:ok, %Scan{}}

      iex> update_scan(scan, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_scan(%Scan{} = scan, attrs) do
    scan
    |> Scan.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a scan.

  ## Examples

      iex> delete_scan(scan)
      {:ok, %Scan{}}

      iex> delete_scan(scan)
      {:error, %Ecto.Changeset{}}

  """
  def delete_scan(%Scan{} = scan) do
    Repo.delete(scan)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking scan changes.

  ## Examples

      iex> change_scan(scan)
      %Ecto.Changeset{data: %Scan{}}

  """
  def change_scan(%Scan{} = scan, attrs \\ %{}) do
    Scan.changeset(scan, attrs)
  end

  def create_findings(attrs_list) do
    Repo.insert_all(Finding, attrs_list)
  end

  def list_findings_for_scan(scan_id, params \\ %{}) do
    query = from(f in Finding, where: f.scan_id == ^scan_id)

    Repo.paginate(query, %{page: params["page"], page_size: params["page_size"] || 50})
  end
end
