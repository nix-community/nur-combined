{
  lib,
  fetchFromGitHub,
  rustPlatform,
  udev,
  pkg-config,
  openssl,
}:

rustPlatform.buildRustPackage {
  pname = "rust-u2f";
  version = "0.4.2";

  src = fetchFromGitHub {
    owner = "danstiner";
    repo = "rust-u2f";
    rev = "da1c12db6167f51c46091d45a274a56ab67e45e7";
    hash = "sha256-413T3bUC6enqhwr6YiBEK9RRV5cHHPO1M682YiiSUMk=";
  };

  cargoHash = "sha256-yKjjpZf2qMMiTPF/k0Fm7vPFdifZUzZ8rzR+epfncdk=";

  nativeBuildInputs = [
    pkg-config
    rustPlatform.bindgenHook
  ];

  buildInputs = [
    udev
    openssl
  ];

  meta = {
    description = "U2F security token emulator written in Rust";
    homepage = "https://github.com/danstiner/rust-u2f";
    license = with lib.licenses; [ asl20 ];
  };

}
