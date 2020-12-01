defmodule TwitterCloneElixir.Repo do
  use Ecto.Repo,
    otp_app: :twitter_clone_elixir,
    adapter: Ecto.Adapters.Postgres
end
