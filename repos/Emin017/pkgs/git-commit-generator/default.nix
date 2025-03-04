{
  pkgs,
  rustPlatform,
  pkg-config,
  openssl,
  fetchFromGitHub,
}:
rustPlatform.buildRustPackage {
  pname = "git-commit-generator";
  version = "v0.1.0";

  cargoHash = "sha256-/AyoFffn9n0nCdvJc8BMrvpENixZLgnWUoQC0/LU++8=";
  useFetchCargoVendor = true;

  src = fetchFromGitHub {
    owner = "Emin017";
    repo = "git-commit-generator";
    rev = "f6428000d74ce3076a5c9c10533407dcacd98685";
    hash = "sha256-u+mPdZy981ZbQenI5JY6OK2qBw1zq+V/iTTkPUTei9o=";
  };

  PKG_CONFIG_PATH = "${pkgs.openssl.dev}/lib/pkgconfig";
  nativeBuildInputs = [
    pkg-config
  ];
  buildInputs = [
    openssl
  ];
}