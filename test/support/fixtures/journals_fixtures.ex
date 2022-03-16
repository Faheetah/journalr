defmodule Journalr.JournalsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Journalr.Journals` context.
  """

  def unique_journal_name, do: "journal#{System.unique_integer()}"

  @doc """
  Generate a journal.
  """
  def journal_fixture(attrs \\ %{}) do
    {:ok, journal} =
      attrs
      |> Enum.into(%{
        public: true,
        name: unique_journal_name()
      })
      |> Journalr.Journals.create_journal()

    journal
  end

  @doc """
  Generate a page.
  """
  def page_fixture(attrs \\ %{}) do
    {:ok, page} =
      attrs
      |> Enum.into(%{
        content: "some content",
        public: true
      })
      |> Journalr.Journals.create_page()

    page
  end
end
