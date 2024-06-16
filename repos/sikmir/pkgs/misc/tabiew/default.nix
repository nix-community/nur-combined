{
  lib,
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

  meta = {
    description = "A lightweight TUI app to view and query CSV files";
    homepage = "https://github.com/shshemi/tabiew";
    license = lib.licenses.mit;
    maintainers = [ lib.maintainers.sikmir ];
    platforms = lib.platforms.unix;
    mainProgram = "tw";
  };
}
