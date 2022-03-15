defmodule Journalr.Journals.Journal do
  use Ecto.Schema
  import Ecto.Changeset

  alias Journalr.Accounts.User

  schema "journals" do
    field :name, :string
    field :public, :boolean, default: false
    belongs_to :user, User

    timestamps()
  end

  @doc false
  def changeset(journal, attrs) do
    journal
    |> cast(attrs, [:name, :public])
    |> validate_required([:name, :public])
  end
end
