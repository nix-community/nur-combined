{
  lib,
  pkgs,
  rustPlatform,
  sqlx-cli,
}:
rustPlatform.buildRustPackage rec {
  pname = "flathunter";
  version = "0.1.0";

  src = pkgs.fetchgit {
    url = "https://codeberg.org/SebRut/flathunter-rust";
    branchName = "main";
    rev = "6aad8edad1e35a06dae00e1e9625c10a04dad7b4";
    hash = "sha256-35bM0goZw1M2yIJlUUxDDR+AUoFTFl3wYhRuwSE0yaE=";
  };

  nativeBuildInputs = [ sqlx-cli ];

  preBuild = ''
    export DATABASE_URL=sqlite://db.sqlite3
    sqlx database create
    sqlx migrate run --source flathunter/migrations/
    cargo sqlx prepare --workspace
  '';

  useFetchCargoVendor = true;
  cargoHash = "sha256-hcTLcNN+/Vqe2FJRwaT75I1N7Em/3mJVJYrqoqYJwXg=";
}
