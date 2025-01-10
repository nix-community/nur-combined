{
  lib,
  rustPlatform,
  fetchFromGitHub,
  pkg-config,
  sqlite,
  zstd,
  stdenv,
  darwin,
  nixosTests,
}:

rustPlatform.buildRustPackage rec {
  pname = "wastebin";
  version = "2.5.0-unstable";

  src = fetchFromGitHub {
    owner = "FliegendeWurst";
    repo = "wastebin";
    rev = "22c8dfd2c98b308f2c6c779428d73d97627e010b";
    hash = "sha256-cNo5Q3Jti60kEoer8cad6uEfiUzctFrtPu7lyQBp9Nk=";
  };

  cargoHash = "sha256-kQxTAt7xzCvLyhvXAmVac5D1sJEr41e0X+sKO/qEvJs=";

  nativeBuildInputs = [
    pkg-config
  ];

  buildInputs = [
    sqlite
    zstd
  ];

  env = {
    ZSTD_SYS_USE_PKG_CONFIG = "1";
  };

  meta = with lib; {
    description = "Wastebin is a pastebin - with all of FliegendeWurst's PRs merged";
    homepage = "https://github.com/FliegendeWurst/wastebin";
    changelog = "https://github.com/FliegendeWurst/wastebin/commit/wip";
    license = licenses.mit;
    maintainers = with maintainers; [
      fliegendewurst
    ];
    mainProgram = "wastebin";
  };
}
