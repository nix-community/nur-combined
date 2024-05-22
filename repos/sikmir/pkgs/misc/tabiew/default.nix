{
  lib,
  stdenv,
  rustPlatform,
  fetchFromGitHub,
}:

rustPlatform.buildRustPackage rec {
  pname = "tabiew";
  version = "0.3.2";

  src = fetchFromGitHub {
    owner = "shshemi";
    repo = "tabiew";
    rev = "v${version}";
    hash = "sha256-rIEt2ngomxiFzzruVzhSVbi+Zye/tW1QGFqgONpDYV0=";
  };

  cargoHash = "sha256-CMqMn29j70f/3YFWtWkW8J5dCxXf5HtaIrl2yudipTQ=";

  meta = with lib; {
    description = "A lightweight TUI app to view and query CSV files";
    inherit (src.meta) homepage;
    license = licenses.mit;
    maintainers = [ maintainers.sikmir ];
    platforms = platforms.unix;
    mainProgram = "tw";
  };
}
