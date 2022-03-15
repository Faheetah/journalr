defmodule JournalrWeb.JournalLiveTest do
  use JournalrWeb.ConnCase

  import Phoenix.LiveViewTest
  import Journalr.JournalsFixtures

  @create_attrs %{public: true}
  @update_attrs %{public: false}
  @invalid_attrs %{public: false}

  defp create_journal(_) do
    journal = journal_fixture()
    %{journal: journal}
  end

  describe "Index" do
    setup [:create_journal]

    test "lists all journals", %{conn: conn} do
      {:ok, _index_live, html} = live(conn, Routes.journal_index_path(conn, :index))

      assert html =~ "Listing Journals"
    end

    test "saves new journal", %{conn: conn} do
      {:ok, index_live, _html} = live(conn, Routes.journal_index_path(conn, :index))

      assert index_live |> element("a", "New Journal") |> render_click() =~
               "New Journal"

      assert_patch(index_live, Routes.journal_index_path(conn, :new))

      assert index_live
             |> form("#journal-form", journal: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      {:ok, _, html} =
        index_live
        |> form("#journal-form", journal: @create_attrs)
        |> render_submit()
        |> follow_redirect(conn, Routes.journal_index_path(conn, :index))

      assert html =~ "Journal created successfully"
    end

    test "updates journal in listing", %{conn: conn, journal: journal} do
      {:ok, index_live, _html} = live(conn, Routes.journal_index_path(conn, :index))

      assert index_live |> element("#journal-#{journal.id} a", "Edit") |> render_click() =~
               "Edit Journal"

      assert_patch(index_live, Routes.journal_index_path(conn, :edit, journal))

      assert index_live
             |> form("#journal-form", journal: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      {:ok, _, html} =
        index_live
        |> form("#journal-form", journal: @update_attrs)
        |> render_submit()
        |> follow_redirect(conn, Routes.journal_index_path(conn, :index))

      assert html =~ "Journal updated successfully"
    end

    test "deletes journal in listing", %{conn: conn, journal: journal} do
      {:ok, index_live, _html} = live(conn, Routes.journal_index_path(conn, :index))

      assert index_live |> element("#journal-#{journal.id} a", "Delete") |> render_click()
      refute has_element?(index_live, "#journal-#{journal.id}")
    end
  end

  describe "Show" do
    setup [:create_journal]

    test "displays journal", %{conn: conn, journal: journal} do
      {:ok, _show_live, html} = live(conn, Routes.journal_show_path(conn, :show, journal))

      assert html =~ "Show Journal"
    end

    test "updates journal within modal", %{conn: conn, journal: journal} do
      {:ok, show_live, _html} = live(conn, Routes.journal_show_path(conn, :show, journal))

      assert show_live |> element("a", "Edit") |> render_click() =~
               "Edit Journal"

      assert_patch(show_live, Routes.journal_show_path(conn, :edit, journal))

      assert show_live
             |> form("#journal-form", journal: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      {:ok, _, html} =
        show_live
        |> form("#journal-form", journal: @update_attrs)
        |> render_submit()
        |> follow_redirect(conn, Routes.journal_show_path(conn, :show, journal))

      assert html =~ "Journal updated successfully"
    end
  end
end
