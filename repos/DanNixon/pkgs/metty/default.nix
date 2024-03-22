{
  lib,
  stdenv,
  fetchFromGitHub,
  rustPlatform,
}:
rustPlatform.buildRustPackage rec {
  pname = "metty";
  version = "2024.3.0";

  src = fetchFromGitHub {
    owner = "DanNixon";
    repo = "metty";
    rev = "v${version}";
    hash = "sha256-76pTWzHpJn08hrZkYNci9B0vViUrirqMf3XYmTBcNeE=";
  };

  cargoHash = "sha256-qR9UKHWp8CdYTPsfcJ7kUHJmpmEHbla7A9f4/mPZ9Ic=";

  meta = {
    description = "A CLI tool for getting real time information about the Tyne and Wear Metro.";
    homepage = "https://github.com/DanNixon/metty";
    platforms = lib.platforms.unix;
    license = lib.licenses.mit;
  };
}
