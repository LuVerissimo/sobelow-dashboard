defmodule SobelowDashboard.Repo.Migrations.CreateScans do
  use Ecto.Migration

  def change do
    create table(:scans) do
      add :project_id, references(:projects, on_delete: :nothing)
      add :status, :string, default: "pending"

      timestamps(type: :utc_datetime)
    end

    create index(:scans, [:project_id])
  end
end
