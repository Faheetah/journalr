defmodule Journalr.Journals.PageTag do
  use Ecto.Schema
  import Ecto.Changeset

  alias Journalr.Journals.Page
  alias Journalr.Journals.Tag

  schema "pages_tags" do
    belongs_to :page, Page
    belongs_to :tag, Tag
  end

  @doc false
  def changeset(tags, attrs) do
    tags
    |> cast(attrs, [:page_id, :tag_id])
  end
end
