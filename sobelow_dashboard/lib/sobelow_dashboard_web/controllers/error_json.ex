defmodule SobelowDashboardWeb.ErrorJSON do
  # This renders a 404
  def render("404.json", _assigns) do
    %{errors: %{detail: "Not Found"}}
  end

  # This renders a 500
  def render("500.json", _assigns) do
    %{errors: %{detail: "Internal Server Error"}}
  end
end
