defmodule SobelowDashboard.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      SobelowDashboardWeb.Telemetry,
      SobelowDashboard.Repo,
      {DNSCluster, query: Application.get_env(:sobelow_dashboard, :dns_cluster_query) || :ignore},
      {Phoenix.PubSub, name: SobelowDashboard.PubSub},
      # Start a worker by calling: SobelowDashboard.Worker.start_link(arg)
      # {SobelowDashboard.Worker, arg},
      # Start to serve requests, typically the last entry
      SobelowDashboardWeb.Endpoint
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: SobelowDashboard.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    SobelowDashboardWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
