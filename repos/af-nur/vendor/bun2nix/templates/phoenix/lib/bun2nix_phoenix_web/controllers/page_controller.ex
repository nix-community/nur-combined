defmodule Bun2nixPhoenixWeb.PageController do
  use Bun2nixPhoenixWeb, :controller

  def home(conn, _params) do
    render(conn, :home)
  end
end
