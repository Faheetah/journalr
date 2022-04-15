defmodule Journalr.Repo.Migrations.AddCurrentJournalToUsers do
  use Ecto.Migration

  def change do
    alter table(:users) do
      add(:current_journal, :integer)
    end
  end
end
