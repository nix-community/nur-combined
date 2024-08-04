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
    rev = "27b20b10d7f03fe6a1a3207b9bb209ad8b744bcd";
    hash = "sha256-/W6PYKnngBd7IRZJwJgTy6LP/CgI189YVkU3MNrNEX0=";
  };

  nativeBuildInputs = [ sqlx-cli ];

  preBuild = ''
    export DATABASE_URL=sqlite://db.sqlite3
    sqlx database create
    sqlx migrate run --source flathunter/migrations/
    cargo sqlx prepare --workspace
  '';

  cargoHash = "sha256-oMdKpooIwzkr58i0eWNUKQEmTxSHexndQIzEZnqlaqs=";
}
