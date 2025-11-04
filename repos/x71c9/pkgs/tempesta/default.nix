{ lib, rustPlatform, fetchFromGitHub }:

rustPlatform.buildRustPackage rec {
  pname = "tempesta";
  version = "0.1.0"; # without "v"

  # Pin the source to an immutable tag/commit
  src = fetchFromGitHub {
    owner = "x71c9";
    repo = "tempesta";
    rev = "v${version}";
    hash = "sha256-CwkLOLpXbjkSi34nMVBOuUw9DtyWics/FO2fX65pa5Q=";
  };

  # Cargo dependency vendor hash (computed by Nix)
  cargoHash = "sha256-98dADUE3jFmHj/E1n79merNznymRRdoTYbAlP6qXLgU=";

  # Enable when you have tests (recommended)
  doCheck = false;

  # If the binary name differs from pname, set mainProgram accordingly
  mainProgram = "tempesta";

  meta = with lib; {
    description = "The fastest and lightest bookmark manager CLI written in Rust";
    homepage = "https://github.com/x71c9/tempesta";
    license = licenses.mit;
    maintainers = []; # keep empty unless you're in nixpkgs' maintainers set
    platforms = platforms.linux ++ platforms.darwin;
  };
}

