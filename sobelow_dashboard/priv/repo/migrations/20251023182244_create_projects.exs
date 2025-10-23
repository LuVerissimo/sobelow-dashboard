defmodule SobelowDashboard.Repo.Migrations.CreateProjects do
  use Ecto.Migration

  def change do
    create table(:projects) do
      add :git_url, :string
      add :name, :string
      add :status, :string, default: "pending"

      timestamps(type: :utc_datetime)
    end
  end
end
