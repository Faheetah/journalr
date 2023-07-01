alias Journalr.Accounts

accounts = [
  {"admin", true},
  {"test", true},
  {"normal", false}
]

Enum.each(accounts, fn {name, is_admin} ->
  unless Accounts.get_user_by_email("#{name}@test.local") do
    {:ok, _} = Accounts.register_user(%{
      email: "#{name}@test.local",
      username: name,
      password: name,
      password_confirmation: name,
      is_admin: is_admin
    })
  end
end)

test_user = Journalr.Accounts.get_user_by_email("test@test.local")
{:ok, test_journal} = Journalr.Journals.create_journal(%{"name" => "test", "user_id" => test_user.id})

Enum.map(0..500, fn i ->
  {:ok, _} = Journalr.Journals.create_page(%{
    "content" => "#{i} ---- Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.",
    "color" => Enum.random(~w[white red yellow green blue]),
    "journal_id" => test_journal.id
  })
end)
