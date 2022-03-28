defmodule Journalr.Journals.Tag do
  use Ecto.Schema
  import Ecto.Changeset

  alias Journalr.Journals.PageTag

  schema "tags" do
    field :tag, :string
    has_many :pages_tags, PageTag, on_delete: :delete_all

    timestamps()
  end

  @doc false
  def changeset(tags, attrs) do
    tags
    |> cast(attrs, [:tag])
    |> validate_required([:tag])
  end
end
