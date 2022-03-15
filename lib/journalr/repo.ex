defmodule Journalr.Repo do
  use Ecto.Repo,
    otp_app: :journalr,
    adapter: Ecto.Adapters.Postgres
end
