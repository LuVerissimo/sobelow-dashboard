defmodule SobelowDashboard.Scans.Scan do
  use Ecto.Schema
  import Ecto.Changeset

  alias SobelowDashboard.Scans.Project

  schema "scans" do
    field(:status, :string)

    belongs_to(:project, Project)

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(scan, attrs) do
    scan
    |> cast(attrs, [:status, :project_id])
    |> validate_required([:status, :project_id])
  end
end
