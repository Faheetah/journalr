defmodule Journalr.JournalsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Journalr.Journals` context.
  """

  @doc """
  Generate a journal.
  """
  def journal_fixture(attrs \\ %{}) do
    {:ok, journal} =
      attrs
      |> Enum.into(%{
        public: true
      })
      |> Journalr.Journals.create_journal()

    journal
  end
end
