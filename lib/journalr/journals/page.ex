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
    |> validate_inclusion(:color, ~w[white red yellow green blue])
    |> calculate_offset(attrs)
  end

  defp calculate_offset(changeset, %{"tz_offset" => tz_offset}) when is_binary(tz_offset) do
    {offset, _} = Integer.parse(tz_offset)
    time = NaiveDateTime.add(changeset.changes.inserted_at, offset * 60)
    put_change(changeset, :inserted_at, time)
  end

  defp calculate_offset(changeset, _), do: changeset
end
