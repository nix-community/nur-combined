{
  lib,
  rustPlatform,
  fetchFromGitHub,
  pkg-config,
  protobuf,
  bzip2,
  stdenv,
  darwin,
}:
# let
#   rustPlatform = pkgs.makeRustPlatform { inherit (pkgs.fenix.minimal) cargo rustc; };
# in

rustPlatform.buildRustPackage {
  pname = "typst-ts-cli";
  version = "test";

  src = fetchFromGitHub {
    owner = "Myriad-Dreamin";
    repo = "typst.ts";
    rev = "af4962758e6ed2e8bbfe4f4ad14086d078ccb0b2";
    hash = "sha256-WwqwSAW8yfGohU8t72MAyuj2Uc6irtOqAwOCdkc7h2M=";
  };
  cargoBuildFlags = "-p typst-ts-cli";
  cargoLock = {
    lockFile = ./lock/typst-ts-cli.lock;
    outputHashes = {
      "typst-0.11.1" = "sha256-Y32A+PmuTzgNDcbkLo4HCH+E864nJ8uFFhAydgEEoNo=";
      "typst-dev-assets-0.11.1" = "sha256-SMRtitDHFpdMEoOuPBnC3RBTyZ96hb4KmMSCXpAyKfU=";
    };

  };

  # cargoLock = {
  #   lockFile = ./lock/avbroot.lock;
  #   outputHashes = {
  #     "bzip2-0.4.4" = "sha256-9YKPFvaGNdGPn2mLsfX8Dh90vR+X4l3YSrsz0u4d+uQ=";
  #     "zip-0.6.6" = "sha256-oZQOW7xlSsb7Tw8lby4LjmySpWty9glcZfzpPuQSSz0=";
  #   };
  # };

  # nativeBuildInputs = [
  #   pkg-config
  #   protobuf
  # ];

  buildInputs =
    [
    ];

  meta = {
    maintainers = with lib.maintainers; [ oluceps ];
    mainProgram = "cli";
  };
}
