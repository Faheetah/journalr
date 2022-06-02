defmodule JournalrWeb.JournalLive.Search do
  @moduledoc false

  use JournalrWeb, :live_view

  alias Journalr.Accounts
  alias Journalr.Journals
  alias Journalr.Repo

  on_mount JournalrWeb.JournalLive.TimezoneHook

  @impl true
  def mount(%{"tag" => tag_name}, session, socket) do
    user =
      session["user_token"]
      |> Accounts.get_user_by_session_token()

    tag = Journals.get_tag_by_name(tag_name)
    if tag do
      {
        :ok,
        socket
        |> assign(:page_title, "Journalr: showing tag - #{tag_name}")
        |> assign(:pages, Journals.list_pages_by_tag(tag, user))
        |> assign(:tag, tag)
        |> assign(:user, user)
        |> assign(:offset, 0)
        |> assign(:tz_offset, nil),
        temporary_assigns: [posts: []]
      }
    else
      {
        :ok,
        socket
        |> put_flash(:error, "no tag found")
        |> assign(:pages, [])
      }
    end
  end

  @impl true
  def handle_info({:page_deleted, page}, socket) do
    {:noreply, assign(socket, :pages, [page])}
  end

  @impl true
  def handle_event("load-more", _, %{assigns: assigns} = socket) do
    {
      :noreply,
      socket
      |> assign(:pages, Journals.list_pages_by_tag(assigns.tag, assigns.user, assigns.offset + 1))
      |> assign(offset: assigns.offset + 1)
    }
  end

  def handle_event("highlight", %{"id" => id, "color" => color}, socket) do
    {:ok, page} =
      Journals.get_page!(id)
      |> Journals.update_page(%{"color" => color})

    {:noreply, assign(socket, :pages, [Repo.preload(page, :journal)])}
  end

  def handle_event("delete", %{"id" => id}, socket) do
    {:ok, page} =
      Journals.get_page!(id)
      |> Journals.delete_page()

    send(self(), {:page_deleted, page})

    {:noreply, socket}
  end
end
