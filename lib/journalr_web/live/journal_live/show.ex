defmodule JournalrWeb.JournalLive.Show do
  @moduledoc false

  use JournalrWeb, :live_view

  alias Journalr.Accounts
  alias Journalr.Journals
  alias Journalr.Journals.Page

  on_mount JournalrWeb.JournalLive.TimezoneHook

  @impl true
  def mount(%{"id" => journal_id} = params, session, socket) do
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
        |> assign(:filter, Map.get(params, "filter"))
        |> assign(:tz_offset, nil)
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
      |> assign(:pages, load_pages(journal, socket.assigns.offset, socket.assigns.filter))
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

  @impl true
  def handle_event("load-more", _, %{assigns: assigns} = socket) do
    if assigns.offset do
      new_pages = load_pages(assigns.journal, assigns.offset + 1, socket.assigns.filter)

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
    page = Journals.get_page!(id)
    new_color = get_highlight(page.color, color)
    {:ok, page} = Journals.update_page(page, %{"color" => new_color})
    {:noreply, assign(socket, :pages, [page])}
  end

  def handle_event("filter-highlight", %{"color" => color}, socket) do
    if socket.assigns.filter == color do
      {
        :noreply,
        push_redirect(socket, to: Routes.journal_show_path(socket, :show, socket.assigns.journal.id))
      }
    else
      {
        :noreply,
        push_redirect(socket, to: Routes.journal_show_path(socket, :show, socket.assigns.journal.id, filter: color))
      }
    end
  end

  def handle_event("delete", %{"id" => id}, socket) do
    {:ok, page} =
      Journals.get_page!(id)
      |> Journals.delete_page()

    {:noreply, assign(socket, :pages, [page])}
  end

  def handle_event("delete-journal", %{"id" => id}, socket) do
    journal = Journals.get_journal!(id)
    {:ok, _} = Journals.delete_journal(journal)

    user = socket.assigns.current_user
    if user.current_journal != id do
      Journals.update_user_current_journal(user, nil)
    end

    {
      :noreply,
      socket
      |> assign(:journals, Journals.list_journals())
      |> push_redirect(to: "/")
    }
  end

  defp get_highlight(original, new) when original == new, do: "white"
  defp get_highlight(_, new), do: new

  defp load_pages(journal, offset, filter \\ nil) do
    Journals.list_pages_for_journal(journal, offset, filter)
  end
end
