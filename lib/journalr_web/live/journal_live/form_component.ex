defmodule JournalrWeb.JournalLive.FormComponent do
  use JournalrWeb, :live_component

  alias Journalr.Journals

  @impl true
  def update(%{journal: journal} = assigns, socket) do
    changeset = Journals.change_journal(journal)

    {:ok,
     socket
     |> assign(assigns)
     |> assign(:changeset, changeset)}
  end

  @impl true
  def handle_event("validate", %{"journal" => journal_params}, socket) do
    changeset =
      socket.assigns.journal
      |> Journals.change_journal(journal_params)
      |> Map.put(:action, :validate)

    {:noreply, assign(socket, :changeset, changeset)}
  end

  def handle_event("save", %{"journal" => journal_params}, socket) do
    save_journal(socket, socket.assigns.action, journal_params)
  end

  defp save_journal(socket, :edit, journal_params) do
    case Journals.update_journal(socket.assigns.journal, journal_params) do
      {:ok, _journal} ->
        {:noreply,
         socket
         |> put_flash(:info, "Journal updated successfully")
         |> push_redirect(to: socket.assigns.return_to)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, :changeset, changeset)}
    end
  end

  defp save_journal(socket, :new, journal_params) do
    case Journals.create_journal(journal_params) do
      {:ok, _journal} ->
        {:noreply,
         socket
         |> put_flash(:info, "Journal created successfully")
         |> push_redirect(to: socket.assigns.return_to)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, changeset: changeset)}
    end
  end
end
