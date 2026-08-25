{
  lib,
  rustPlatform,
  fetchFromGitHub,
  pkg-config,
  openssl,
  sqlite,
  stdenv,
}:

rustPlatform.buildRustPackage {
  pname = "openhuman";
  version = "unstable-2026-08-26";

  src = fetchFromGitHub {
    owner = "tinyhumansai";
    repo = "openhuman";
    rev = "be6e7f6abbc3b5c79af277688767ea1597ede4fc";
    hash = "sha256-dydhNsCSRBzpUE41RL4CFqziilW0wRrWaRhSoQir+SI=";
    fetchSubmodules = true;
  };

  cargoHash = "sha256-l+p+r4hKuMoBPPJ4LXgGw7P6iQnEX8uf8Z1pwsEW3R4=";

  nativeBuildInputs = [
    pkg-config
  ];

  buildInputs = [
    openssl
    sqlite
  ];

  doCheck = false;

  meta = with lib; {
    description = "OpenHuman core business logic and RPC server";
    homepage = "https://github.com/tinyhumansai/openhuman";
    license = licenses.gpl3Only;
    maintainers = with maintainers; [ ];
    mainProgram = "openhuman-core";
  };
}
