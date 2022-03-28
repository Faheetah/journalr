defmodule Journalr.Repo.Migrations.CreateTags do
  use Ecto.Migration

  def change do
    create table(:tags) do
      add :tag, :citext

      timestamps()
    end

    create table(:pages_tags) do
      add :page_id, references(:pages, on_delete: :delete_all)
      add :tag_id, references(:tags, on_delete: :delete_all)
    end
  end
end
