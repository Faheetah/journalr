defmodule JournalrWeb.JournalLive.Home do
  @moduledoc false

  use JournalrWeb, :live_view

  alias Journalr.Accounts
  alias Journalr.Journals
  alias Journalr.Journals.Journal

  @impl true
  def mount(_params, session, socket) do
    user = Accounts.get_user_by_session_token(session["user_token"])

    {
      :ok,
      socket
      |> assign(:journals, Journals.list_journals_for_user(user))
      |> assign(:current_user, user)
      |> assign(:tz_offset, nil)
    }
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

  defp apply_action(socket, :index, %{}) do
    socket
    |> assign(:page_title, "")
    |> assign(:journal, nil)
  end

  defp apply_action(socket, :index_or_show, _params) do
    current_journal = Journals.get_current_journal(socket.assigns.current_user)

    if current_journal do
      socket
      |> push_redirect(to: Routes.journal_show_path(socket, :show, current_journal))
    else
      socket
      |> push_redirect(to: Routes.journal_index_path(socket, :index))
    end
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    journal = Journals.get_journal!(id)
    {:ok, _} = Journals.delete_journal(journal)

    {:noreply, assign(socket, :journals, Journals.list_journals())}
  end
end
