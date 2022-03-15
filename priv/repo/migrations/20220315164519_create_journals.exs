defmodule Journalr.Repo.Migrations.CreateJournals do
  use Ecto.Migration

  def change do
    create table(:journals) do
      add :name, :string, null: false
      add :public, :boolean, default: false, null: false
      add :user_id, references(:users, on_delete: :delete_all)

      timestamps()
    end

    create index(:journals, [:user_id])
  end
end
