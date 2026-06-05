{
  buildPackages,
  fetchFromGitHub,
  lib,
  rustPlatform,
  rustfmt,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "zecwallet-light-cli";
  version = "1.7.7";

  src = fetchFromGitHub {
    owner = "adityapk00";
    repo = "zecwallet-light-cli";
    rev = "v${finalAttrs.version}";
    hash = "sha256-8qr6GIldJcybQwXbdZxFVGvFPJErLpqCEIuGJw1z0qQ=";
  };

  cargoLock = {
    lockFile = ./Cargo.lock;
    outputHashes = {
      "equihash-0.1.0" = "sha256-/QJoQKBJajNofD71e5rNVzYSw3WqXlIXPVE1BIaKGmE=";
    };
  };

  nativeBuildInputs = [
    rustfmt
  ];

  env.PROTOC = lib.getExe buildPackages.protobuf;

  meta = {
    description = "Zecwallet-Lite is z-Addr first lightwallet for Zcash";
    homepage = "https://github.com/adityapk00/zecwallet-light-cli";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ colinsane ];
  };
})
