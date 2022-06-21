defmodule Journalr.Journals do
  @moduledoc """
  The Journals context.
  """

  import Ecto.Query, warn: false
  alias Journalr.Repo

  alias Journalr.Accounts.User
  alias Journalr.Journals.Journal
  alias Journalr.Journals.PageTag
  alias Journalr.Journals.Tag

  @doc """
  Returns the list of journals.

  ## Examples

      iex> list_journals()
      [%Journal{}, ...]

  """
  def list_journals do
    Repo.all(Journal)
  end

  def list_journals_for_user(user) do
    Repo.all(from j in Journal, where: j.user_id == ^user.id)
  end

  @doc """
  Gets a single journal.

  Raises `Ecto.NoResultsError` if the Journal does not exist.

  ## Examples

      iex> get_journal!(123)
      %Journal{}

      iex> get_journal!(456)
      ** (Ecto.NoResultsError)

  """
  def get_journal!(id), do: Repo.get!(Journal, id)
  def get_journal(id), do: Repo.get(Journal, id)

  # def get_current_journal(%User{:current_journal => nil}), do: nil
  def get_current_journal(%User{:current_journal => id}) do
    if id != nil do
      with {:ok, journal} <- get_journal(id) do
        journal
      end
    end
  end

  def update_user_current_journal(user, journal_id) do
    User.current_journal_changeset(user, %{"current_journal" => journal_id})
    |> Repo.update()
  end

  @doc """
  Creates a journal.

  ## Examples

      iex> create_journal(%{field: value})
      {:ok, %Journal{}}

      iex> create_journal(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_journal(attrs \\ %{}) do
    %Journal{}
    |> Journal.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a journal.

  ## Examples

      iex> update_journal(journal, %{field: new_value})
      {:ok, %Journal{}}

      iex> update_journal(journal, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_journal(%Journal{} = journal, attrs) do
    journal
    |> Journal.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a journal.

  ## Examples

      iex> delete_journal(journal)
      {:ok, %Journal{}}

      iex> delete_journal(journal)
      {:error, %Ecto.Changeset{}}

  """
  def delete_journal(%Journal{} = journal) do
    Repo.delete(journal)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking journal changes.

  ## Examples

      iex> change_journal(journal)
      %Ecto.Changeset{data: %Journal{}}

  """
  def change_journal(%Journal{} = journal, attrs \\ %{}) do
    Journal.changeset(journal, attrs)
  end

  alias Journalr.Journals.Page

  @doc """
  Returns the list of pages.

  ## Examples

      iex> list_pages()
      [%Page{}, ...]

  """
  def list_pages do
    Repo.all(Page)
  end

  @per_page 20
  def list_pages_for_journal(journal, page) do
    offset = page * @per_page

    Repo.all(
      from p in Page,
      where: [journal_id: ^journal.id],
      limit: @per_page,
      offset: ^offset,
      order_by: [desc: p.inserted_at],
      order_by: [desc: p.id]
    )
  end

  def list_pages_for_journal(journal, page, nil), do: list_pages_for_journal(journal, page)
  def list_pages_for_journal(journal, page, color) do
    offset = page * @per_page

    Repo.all(
      from p in Page,
      where: [journal_id: ^journal.id],
      where: [color: ^color],
      limit: @per_page,
      offset: ^offset,
      order_by: [desc: p.inserted_at],
      order_by: [desc: p.id]
    )
  end

  def list_pages_by_tag(tag, user, page \\ 0) do
    offset = page * @per_page

    Repo.all(
      from p in Page,
      preload: [:pages_tags],
      join: pt in PageTag,
      on: pt.tag_id == ^tag.id and pt.page_id == p.id,
      join: j in Journal,
      on: j.user_id == ^user.id and p.journal_id == j.id,
      preload: [:journal],
      limit: @per_page,
      offset: ^offset,
      order_by: [desc: p.inserted_at],
      order_by: [desc: p.id]
    )
    |> Enum.dedup_by(fn page -> page.id end)
  end


  @doc """
  Gets a single page.

  Raises `Ecto.NoResultsError` if the Page does not exist.

  ## Examples

      iex> get_page!(123)
      %Page{}

      iex> get_page!(456)
      ** (Ecto.NoResultsError)

  """
  def get_page!(id), do: Repo.get!(Page, id)

  @doc """
  Creates a page.

  ## Examples

      iex> create_page(%{field: value})
      {:ok, %Page{}}

      iex> create_page(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_page(attrs \\ %{}) do
    pages_tags =
      Regex.scan(~r/#([a-zA-Z0-9]+)/, attrs["content"])
      |> Enum.dedup()
      |> Enum.map(fn [_, tag] ->
        %{
          tag_id: get_or_insert_tag(tag).id,
          user_id: get_journal!(attrs["journal_id"]).id
        }
      end)

    %Page{}
    |> Page.changeset(Map.put(attrs, "pages_tags", pages_tags))
    |> Repo.insert()
  end

  @doc """
  Updates a page.

  ## Examples

      iex> update_page(page, %{field: new_value})
      {:ok, %Page{}}

      iex> update_page(page, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_page(%Page{} = page, attrs) do
    page
    |> Page.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a page.

  ## Examples

      iex> delete_page(page)
      {:ok, %Page{}}

      iex> delete_page(page)
      {:error, %Ecto.Changeset{}}

  """
  def delete_page(%Page{} = page) do
    Repo.delete(page)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking page changes.

  ## Examples

      iex> change_page(page)
      %Ecto.Changeset{data: %Page{}}

  """
  def change_page(%Page{} = page, attrs \\ %{}) do
    Page.changeset(page, attrs)
  end

  def get_tag_by_name(tag) do
    Repo.get_by(Tag, tag: tag)
  end

  def get_or_insert_tag(tag) do
    Repo.get_by(Tag, tag: tag) || Repo.insert!(%Tag{tag: tag})
  end
end
