defmodule JournalrWeb.JournalLive.Show do
  @moduledoc false

  use JournalrWeb, :live_view

  alias Journalr.Accounts
  alias Journalr.Journals
  alias Journalr.Journals.Page

  @impl true
  def mount(%{"id" => journal_id}, session, socket) do
    user =
      session["user_token"]
      |> Accounts.get_user_by_session_token()

    if Journals.get_journal!(journal_id).user_id == user.id do
      if connected?(socket) do
        Phoenix.PubSub.subscribe(Journalr.PubSub, "pages-#{journal_id}")
      end

      {:ok, assign(socket, :journals, Journals.list_journals_for_user(user))}
    else
      {
        :ok,
        socket
        |> put_flash(:error, "Log in to view this journal")
        |> push_redirect(to: "/")
      }
    end
  end

  @impl true
  def handle_params(%{"id" => id}, _, socket) do
    journal = Journals.get_journal!(id)
    {
      :noreply,
      socket
      |> assign(:page_title, page_title(socket.assigns.live_action))
      |> assign(:journal, journal)
      |> assign(:pages, Journals.list_pages_for_journal(journal))
      |> assign(:page, %Page{})
    }
  end

  @impl true
  def handle_info({:page_created, page}, socket) when page.journal_id == socket.assigns.journal.id do
    {
      :noreply,
      update(socket, :pages, fn pages -> [page | pages] end)
    }
  end

  def handle_info({:page_created, _page}, socket), do: socket

  defp page_title(:show), do: "Show Journal"
  defp page_title(:edit), do: "Edit Journal"
end
