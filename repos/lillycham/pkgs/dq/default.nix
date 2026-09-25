{
  lib,
  rustPlatform,
  fetchFromGitHub,
}:
rustPlatform.buildRustPackage {
  pname = "dq";
  version = "0.1.0-unstable-2026-09-24";

  src = fetchFromGitHub {
    owner = "lillycham";
    repo = "dq";
    rev = "77b2eb718242e5cbb8d6ee898f33e72d7b49c5b9";
    hash = "sha256-MWBS7OPW/+TG8RDVij0zkroECi5KT24MT48wbN/x9Sw=";
  };

  cargoHash = "sha256-cISbSy5oj7U+CRyawYmFBmwfQYD9th4ioJNqOPcqzao=";

  meta = {
    description = "Query and manipulate directory trees with jq expressions";
    homepage = "https://github.com/lillycham/dq";
    license = lib.licenses.gpl3Plus;
    mainProgram = "dq";
  };
}
