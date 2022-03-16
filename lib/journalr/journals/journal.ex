defmodule Journalr.Journals.Journal do
  @moduledoc false

  use Ecto.Schema
  import Ecto.Changeset

  alias Journalr.Accounts.User
  alias Journalr.Journals.Page

  schema "journals" do
    field :name, :string
    field :public, :boolean, default: false
    belongs_to :user, User
    has_many :pages, Page, on_delete: :delete_all

    timestamps()
  end

  @doc false
  def changeset(journal, attrs) do
    journal
    |> cast(attrs, [:name, :public, :user_id])
    |> cast_assoc(:user)
    |> validate_required([:name, :public])
  end
end
