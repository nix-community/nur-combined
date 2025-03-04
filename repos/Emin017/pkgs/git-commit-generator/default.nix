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

  cargoHash = "sha256-XYQM6+NSp56oL3Y8WKnAUZOo+S2Uvt1FbIs9TvilEyU=";
  useFetchCargoVendor = true;

  src = fetchFromGitHub {
    owner = "Emin017";
    repo = "git-commit-generator";
    rev = "e4d9146f463444017aa0872a3b29671a95194ad7";
    hash = "sha256-K9CEVYvnnYJnOIt3NtxwYmzbpG+QvrSVdAPuOjtpmyM=";
  };

  PKG_CONFIG_PATH = "${pkgs.openssl.dev}/lib/pkgconfig";
  nativeBuildInputs = [
    pkg-config
  ];
  buildInputs = [
    openssl
  ];
}