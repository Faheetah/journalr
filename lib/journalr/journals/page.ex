defmodule Journalr.Journals.Page do
  @moduledoc false

  use Ecto.Schema
  import Ecto.Changeset

  alias Journalr.Journals.Journal
  alias Journalr.Journals.PageTag

  schema "pages" do
    field :content, :string
    field :color, :string, default: "white"
    belongs_to :journal, Journal
    has_many :pages_tags, PageTag, on_delete: :delete_all

    timestamps()
  end

  @doc false
  def changeset(page, attrs) do
    page
    |> cast(attrs, [:content, :color, :journal_id, :inserted_at])
    |> cast_assoc(:journal)
    |> cast_assoc(:pages_tags)
    |> validate_required([:content])
  end
end
