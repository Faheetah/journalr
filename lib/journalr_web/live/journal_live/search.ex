defmodule JournalrWeb.JournalLive.Search do
  @moduledoc false

  use JournalrWeb, :live_view

  alias Journalr.Accounts
  alias Journalr.Journals
  alias Journalr.Journals.Page

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
        |> assign(:pages, Journals.list_pages_by_tag(tag, user))
        |> assign(:tag, tag)
        |> assign(:user, user)
        |> assign(:offset, 0)
        |> assign(:tz_offset, nil)
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
  def handle_params(_, _, socket) do
    {
      :noreply,
      socket
      |> assign(:page_title, page_title(socket.assigns.live_action))
      |> assign(:page, %Page{})
    }
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

  defp page_title(_), do: "Search"
end
