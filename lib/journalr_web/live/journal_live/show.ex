defmodule JournalrWeb.JournalLive.Show do
  @moduledoc false

  use JournalrWeb, :live_view

  alias Journalr.Accounts
  alias Journalr.Journals
  alias Journalr.Journals.Page

  on_mount JournalrWeb.JournalLive.TimezoneHook

  @impl true
  def mount(%{"id" => journal_id}, session, socket) do
    user =
      session["user_token"]
      |> Accounts.get_user_by_session_token()

    if user.current_journal != journal_id do
      Journals.update_user_current_journal(user, journal_id)
    end

    if Journals.get_journal!(journal_id).user_id == user.id do
      if connected?(socket) do
        Phoenix.PubSub.subscribe(Journalr.PubSub, "pages-#{journal_id}")
      end

      {
        :ok,
        socket
        |> assign(:offset, 0)
        |> assign(:current_user, user)
        |> assign(:tz_offset, nil),
        temporary_assigns: [posts: []]
      }
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
  def handle_params(%{"id" => id}, _uri, socket) do
    journal = Journals.get_journal!(id)
    {
      :noreply,
      socket
      |> assign(:page_title, "Journalr: #{journal.name}")
      |> assign(:journal, journal)
      |> assign(:pages, load_pages(journal, socket.assigns.offset))
      |> assign(:page, %Page{})
    }
  end

  @impl true
  def handle_info({:page_created, page}, socket) when page.journal_id == socket.assigns.journal.id do
    {
      :noreply,
      assign(socket, :pages, [page])
    }
  end

  def handle_info({:page_created, _page}, socket), do: socket

  def handle_info({:page_deleted, page}, socket) do
    {:noreply, assign(socket, :pages, [page])}
  end

  @impl true
  def handle_event("load-more", _, %{assigns: assigns} = socket) do
    if assigns.offset do
      new_pages = load_pages(assigns.journal, assigns.offset + 1)

      if new_pages != [] do
        {
          :noreply,
          socket
          |> assign(:pages, new_pages)
          |> assign(offset: assigns.offset + 1)
        }
      else
        {:noreply, assign(socket, offset: nil)}
      end
    else
      {:noreply, assign(socket, offset: nil)}
    end
  end

  def handle_event("highlight", %{"id" => id, "color" => color}, socket) do
    {:ok, page} =
      Journals.get_page!(id)
      |> Journals.update_page(%{"color" => color})

    {:noreply, assign(socket, :pages, [page])}
  end

  def handle_event("delete", %{"id" => id}, socket) do
    {:ok, page} =
      Journals.get_page!(id)
      |> Journals.delete_page()

    send(self(), {:page_deleted, page})

    {:noreply, socket}
  end

  defp load_pages(journal, offset) do
    Journals.list_pages_for_journal(journal, offset)
  end
end
