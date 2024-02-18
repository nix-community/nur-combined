{ lib
, fetchFromGitHub
, pkgs
}:

let
  rustPlatform = pkgs.makeRustPlatform { inherit (pkgs.fenix.minimal) cargo rustc; };
in

rustPlatform.buildRustPackage rec{
  pname = "restls";
  version = "0.1.1";

  src = fetchFromGitHub {
    rev = "v${version}";
    owner = "3andne";
    repo = pname;
    hash = "sha256-nlQdBwxHVbpOmb9Wq+ap2i4KI1zJYT3SEqvedDbVH8Q=";
  };

  cargoHash = "sha256-KtNLLtStZ7SNndcPxWfNPA2duoXFVePrbNQFPUz2xFg=";

  # RUSTC_BOOTSTRAP = 1;
}
