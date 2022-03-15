defmodule JournalrWeb.JournalLive.Show do
  use JournalrWeb, :live_view

  alias Journalr.Journals

  @impl true
  def mount(_params, _session, socket) do
    {:ok, assign(socket, :journals, list_journals())}
  end

  @impl true
  def handle_params(%{"id" => id}, _, socket) do
    {:noreply,
     socket
     |> assign(:page_title, page_title(socket.assigns.live_action))
     |> assign(:journal, Journals.get_journal!(id))}
  end

  defp page_title(:show), do: "Show Journal"
  defp page_title(:edit), do: "Edit Journal"

  defp list_journals do
    Journals.list_journals()
  end
end
