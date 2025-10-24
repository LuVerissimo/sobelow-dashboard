defmodule SobelowDashboard.Repo do
  use Ecto.Repo,
    otp_app: :sobelow_dashboard,
    adapter: Ecto.Adapters.Postgres

    use Scrivener, page_size: 50
end
