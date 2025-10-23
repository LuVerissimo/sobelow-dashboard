defmodule SobelowDashboard.Repo do
  use Ecto.Repo,
    otp_app: :sobelow_dashboard,
    adapter: Ecto.Adapters.Postgres
end
