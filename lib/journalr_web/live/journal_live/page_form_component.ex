defmodule JournalrWeb.JournalLive.PageFormComponent do
  @moduledoc false

  use JournalrWeb, :live_component

  alias Journalr.Journals
  alias Journalr.Journals.Page

  @impl true
  def update(assigns, socket) do
    {
      :ok,
      socket
      |> assign(assigns)
      |> assign(:changeset, Journals.change_page(%Page{}))
    }
  end

  @impl true
  def handle_event("save", %{"page" => page_params}, socket) do
    {:ok, inserted_at} = NaiveDateTime.from_iso8601(page_params["inserted_at"] <> ":00.00")

    case Journals.create_page(Map.put(page_params, "inserted_at", inserted_at)) do
      {:ok, page} ->
        Phoenix.PubSub.broadcast(Journalr.PubSub, "pages-#{page.journal_id}", {:page_created, page})
        {:noreply, push_redirect(socket, to: socket.assigns.return_to)}

      {:error, %Ecto.Changeset{} = _changeset} ->
        {:noreply, socket |> put_flash(:error, "Could not save page")}
    end
  end
end
