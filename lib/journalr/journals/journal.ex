defmodule Journalr.Journals.Journal do
  use Ecto.Schema
  import Ecto.Changeset

  alias Journalr.Accounts.User

  schema "journals" do
    field :public, :boolean, default: false
    belongs_to :user, User

    timestamps()
  end

  @doc false
  def changeset(journal, attrs) do
    journal
    |> cast(attrs, [:public])
    |> validate_required([:public])
  end
end
