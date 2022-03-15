defmodule JournalrWeb.PageController do
  use JournalrWeb, :controller

  def index(conn, _params) do
    render(conn, "index.html")
  end
end
