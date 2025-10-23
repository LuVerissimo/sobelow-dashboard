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
end
