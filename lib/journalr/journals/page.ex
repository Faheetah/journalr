defmodule Journalr.Journals.Page do
  @moduledoc false

  use Ecto.Schema
  import Ecto.Changeset

  alias Journalr.Journals.Journal

  schema "pages" do
    field :content, :string
    belongs_to :journal, Journal

    timestamps()
  end

  @doc false
  def changeset(page, attrs) do
    page
    |> cast(attrs, [:content, :journal_id, :inserted_at])
    |> cast_assoc(:journal)
    |> validate_required([:content])
  end
end
