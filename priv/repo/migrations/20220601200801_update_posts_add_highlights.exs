defmodule Journalr.Repo.Migrations.UpdatePostsAddHighlights do
  use Ecto.Migration

  def change do
    alter table(:pages) do
      add :color, :text, default: "white"
    end
  end
end
