defmodule JournalrWeb.JournalLive.Index do
  use JournalrWeb, :live_view

  alias Journalr.Journals
  alias Journalr.Journals.Journal

  @impl true
  def mount(_params, _session, socket) do
    {:ok, assign(socket, :journals, list_journals())}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    socket
    |> assign(:page_title, "Edit Journal")
    |> assign(:journal, Journals.get_journal!(id))
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, "New Journal")
    |> assign(:journal, %Journal{})
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Listing Journals")
    |> assign(:journal, nil)
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    journal = Journals.get_journal!(id)
    {:ok, _} = Journals.delete_journal(journal)

    {:noreply, assign(socket, :journals, list_journals())}
  end

  defp list_journals do
    Journals.list_journals()
  end
end
