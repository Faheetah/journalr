defmodule JournalrWeb.JournalLive.PageComponent do
  @moduledoc false

  use JournalrWeb, :live_component

  alias Journalr.Journals

  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  def handle_params(%{"id" => id}, _, socket) do
    page =
      Journals.get_page!(id)

    {
      :noreply,
      socket
      |> assign(:page, page)
    }
  end
end
