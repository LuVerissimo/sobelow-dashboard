defmodule SobelowDashboardWeb.FallbackController do
  @moduledoc """
    Translates controler action result into valid Pluhhg Conn responses.
  """

  use SobelowDashboardWeb, :controller

  def call(conn, {:error, %Ecto.Changeset{} = changeset}) do
    conn
    |> put_status(:unprocessable_entity)
    |> put_view(json: SobelowDashboardWeb.ChangesetJSON)
    |> render(:error, changeset: changeset)
  end

  def call(conn, {:error, :not_found}) do
    conn
    |> put_status(:not_found)
    |> put_view(json: SobelowDashboardWeb.ErrorJSON)
    |> render(:"404")
  end
end
