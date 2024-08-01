{
  lib,
  fetchgit,
  rustPlatform,
  sqlx-cli,
}:
rustPlatform.buildRustPackage rec {
  pname = "flathunter";
  version = "0.1.0";

  src = fetchgit {
    url = "https://codeberg.org/SebRut/flathunter-rust";
    branchName = "main";
    sha256 = "sha256-lvPEs/vV0Z9bQ0LFiO+Xkt0auUZQk1BQQ1o5k+vMMHE=";
  };

  nativeBuildInputs = [ sqlx-cli ];

  preBuild = ''
    export DATABASE_URL=sqlite://db.sqlite3
    sqlx database create
    sqlx migrate run --source flathunter/migrations/
  '';

  cargoHash = "sha256-gz1FvW/FYldxm/nSq8Ssuag1B6EE0vBgRFuLImbghgY=";
}
