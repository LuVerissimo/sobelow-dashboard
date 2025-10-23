defmodule SobelowDashboard.Scans.Scan do
  use Ecto.Schema
  import Ecto.Changeset

  schema "scans" do
    field :status, :string
    field :project_id, :id

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(scan, attrs) do
    scan
    |> cast(attrs, [:status])
    |> validate_required([:status])
  end
end
