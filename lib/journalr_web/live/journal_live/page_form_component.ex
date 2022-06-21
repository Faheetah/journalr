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
      |> assign(:changeset, Journals.change_page(%Page{}, %{inserted_at: NaiveDateTime.local_now()}))
    }
  end

  @impl true
  def handle_event("save", %{"page" => page_params}, socket) do
    case Journals.create_page(page_params) do
      {:ok, page} ->
        Phoenix.PubSub.broadcast(Journalr.PubSub, "pages-#{page.journal_id}", {:page_created, page})
        {
          :noreply,
          socket
          |> assign(:changeset, Journals.change_page(%Page{}, %{inserted_at: NaiveDateTime.local_now()}))
        }

      {:error, %Ecto.Changeset{} = _changeset} ->
        {:noreply, socket |> put_flash(:error, "Could not save page")}
    end
  end
end
