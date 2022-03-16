defmodule Journalr.JournalsTest do
  use Journalr.DataCase

  alias Journalr.Journals

  describe "journals" do
    alias Journalr.Journals.Journal

    import Journalr.JournalsFixtures


    test "list_journals/0 returns all journals" do
      journal = journal_fixture()
      assert Journals.list_journals() == [journal]
    end

    test "get_journal!/1 returns the journal with given id" do
      journal = journal_fixture()
      assert Journals.get_journal!(journal.id) == journal
    end

    test "create_journal/1 with valid data creates a journal" do
      valid_attrs = %{name: unique_journal_name()}

      assert {:ok, %Journal{} = journal} = Journals.create_journal(valid_attrs)
    end

    test "create_journal/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Journals.create_journal(@invalid_attrs)
    end

    test "update_journal/2 with valid data updates the journal" do
      journal = journal_fixture()
      update_attrs = %{content: "false"}

      assert {:ok, %Journal{} = journal} = Journals.update_journal(journal, update_attrs)
      assert journal.content == "false"
    end

    test "update_journal/2 with invalid data returns error changeset" do
      journal = journal_fixture()
      assert {:error, %Ecto.Changeset{}} = Journals.update_journal(journal, @invalid_attrs)
      assert journal == Journals.get_journal!(journal.id)
    end

    test "delete_journal/1 deletes the journal" do
      journal = journal_fixture()
      assert {:ok, %Journal{}} = Journals.delete_journal(journal)
      assert_raise Ecto.NoResultsError, fn -> Journals.get_journal!(journal.id) end
    end

    test "change_journal/1 returns a journal changeset" do
      journal = journal_fixture()
      assert %Ecto.Changeset{} = Journals.change_journal(journal)
    end
  end

  describe "pages" do
    alias Journalr.Journals.Page

    import Journalr.JournalsFixtures

    @invalid_attrs %{content: nil}

    test "list_pages/0 returns all pages" do
      page = page_fixture()
      assert Journals.list_pages() == [page]
    end

    test "get_page!/1 returns the page with given id" do
      page = page_fixture()
      assert Journals.get_page!(page.id) == page
    end

    test "create_page/1 with valid data creates a page" do
      valid_attrs = %{content: "some content", public: true}

      assert {:ok, %Page{} = page} = Journals.create_page(valid_attrs)
      assert page.content == "some content"
    end

    test "create_page/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Journals.create_page(@invalid_attrs)
    end

    test "delete_page/1 deletes the page" do
      page = page_fixture()
      assert {:ok, %Page{}} = Journals.delete_page(page)
      assert_raise Ecto.NoResultsError, fn -> Journals.get_page!(page.id) end
    end

    test "change_page/1 returns a page changeset" do
      page = page_fixture()
      assert %Ecto.Changeset{} = Journals.change_page(page)
    end
  end
end
