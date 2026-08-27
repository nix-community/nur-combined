{
  lib,
  rustPlatform,
  fetchFromGitHub,
  pkg-config,
  openssl,
  sqlite,
  stdenv,
}:

rustPlatform.buildRustPackage rec {
  pname = "openhuman";
  version = "0.63.17";

  src = fetchFromGitHub {
    owner = "tinyhumansai";
    repo = "openhuman";
    rev = "v${version}";
    hash = "sha256-J0n2BAWrymldULyYCsqm9UivOnAzkXsfImn8F3rRf6c=";
    fetchSubmodules = true;
  };

  cargoHash = "sha256-9PDYgvWbKQp92HVH1QxcSholmccsNp0uFzCKtfc9blw=";

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
