defmodule AHappyBotWeb.PageController do
  use AHappyBotWeb, :controller

  def index(conn, _params) do
    render(conn, "index.html")
  end
end
