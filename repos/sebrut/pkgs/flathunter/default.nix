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
    rev = "8f4856636af190a3c357a29eb6a232c50de2417c";
    hash = "sha256-vwTnqF2hZkCu9BQHGja+n0Mkw+q1AS6rrE/0B1RraYg=";
  };

  nativeBuildInputs = [ sqlx-cli ];

  preBuild = ''
    export DATABASE_URL=sqlite://db.sqlite3
    sqlx database create
    sqlx migrate run --source flathunter/migrations/
  '';

  cargoHash = "sha256-oMdKpooIwzkr58i0eWNUKQEmTxSHexndQIzEZnqlaqs=";
}
