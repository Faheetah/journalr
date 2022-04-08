defmodule JournalrWeb.JournalLive.SidebarComponent do
  @moduledoc false

  use JournalrWeb, :live_component

  alias Journalr.Accounts
  alias Journalr.Journals

  def update(%{user: user}, socket) do
    {
      :ok,
      socket
      |> assign(:journals, Journals.list_journals_for_user(user))
      |> assign(:test, "test")
    }
  end

  def handle_params(params, _, socket) do
    {:noreply, socket}
  end
end
