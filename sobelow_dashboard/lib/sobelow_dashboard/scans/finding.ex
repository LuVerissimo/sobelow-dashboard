defmodule SobelowDashboard.Scans.Finding do
  use Ecto.Schema
  import Ecto.Changeset

  schema "findings" do
    field :vulnerability_type, :string
    field :file, :string
    field :line, :integer
    field :confidence, :string
    field :severity, :string
    field :description, :string
    field :scan_id, :id

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(finding, attrs) do
    finding
    |> cast(attrs, [:vulnerability_type, :file, :line, :confidence, :severity, :description])
    |> validate_required([:vulnerability_type, :file, :line, :confidence, :severity, :description])
  end
end
