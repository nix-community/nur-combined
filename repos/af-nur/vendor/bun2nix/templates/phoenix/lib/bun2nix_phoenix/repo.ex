defmodule Bun2nixPhoenix.Repo do
  use Ecto.Repo,
    otp_app: :bun2nix_phoenix,
    adapter: Ecto.Adapters.Postgres
end
