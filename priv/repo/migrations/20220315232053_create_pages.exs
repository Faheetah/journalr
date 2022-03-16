defmodule Journalr.Repo.Migrations.CreatePages do
  use Ecto.Migration

  def change do
    create table(:pages) do
      add :content, :text, null: false
      add :journal_id, references(:journals, on_delete: :delete_all)

      timestamps()
    end

    create index(:pages, [:journal_id])
  end
end
