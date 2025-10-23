defmodule SobelowDashboard.Repo.Migrations.CreateFindings do
  use Ecto.Migration

  def change do
    create table(:findings) do
      add :vulnerability_type, :string
      add :file, :string
      add :line, :integer
      add :confidence, :string
      add :severity, :string
      add :description, :text
      add :scan_id, references(:scans, on_delete: :nothing)

      timestamps(type: :utc_datetime)
    end

    create index(:findings, [:scan_id])
  end
end
