defmodule JournalrWeb.JournalLive.PageFormComponent do
  @moduledoc false

  use JournalrWeb, :live_component

  alias Journalr.Journals

  @impl true
  def update(%{page: page} = assigns, socket) do
    changeset = Journals.change_page(page)

    {:ok,
     socket
     |> assign(assigns)
     |> assign(:changeset, changeset)}
  end

  @impl true
  def handle_event("save", %{"page" => page_params}, socket) do
    save_page(socket, :new, page_params)
  end

  defp save_page(socket, :edit, page_params) do
    case Journals.update_page(socket.assigns.page, page_params) do
      {:ok, _page} ->
        {:noreply,
         socket
         |> put_flash(:info, "Page updated successfully")
         |> push_redirect(to: socket.assigns.return_to)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, :changeset, changeset)}
    end
  end

  defp save_page(socket, :new, page_params) do
    case Journals.create_page(page_params) do
      {:ok, page} ->
        Phoenix.PubSub.broadcast(Journalr.PubSub, "pages-#{page.journal_id}", {:page_created, page})
        {:noreply,
         socket
         |> push_redirect(to: socket.assigns.return_to)}

      {:error, %Ecto.Changeset{} = _changeset} ->
        {
          :noreply,
          socket
          |> put_flash(:error, "Could not save page")
        }
    end
  end
end
