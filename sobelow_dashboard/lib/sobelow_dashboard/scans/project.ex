defmodule SobelowDashboard.Scans.Project do
  use Ecto.Schema
  import Ecto.Changeset

  schema "projects" do
    field :git_url, :string
    field :name, :string

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(project, attrs) do
    project
    |> cast(attrs, [:git_url, :name])
    |> validate_required([:git_url, :name])
  end
end
