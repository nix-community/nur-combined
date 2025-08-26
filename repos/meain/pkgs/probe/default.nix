{
  lib,
  rustPlatform,
  fetchFromGitHub,
  pkg-config,
  openssl,
  stdenv,
  darwin,
}:

rustPlatform.buildRustPackage rec {
  pname = "probe";
  version = "0.6.0-rc31";

  src = fetchFromGitHub {
    owner = "buger";
    repo = "probe";
    rev = "v${version}";
    hash = "sha256-q+1PML9uxZD/pBlek0t+NuU46LohOO3r2NfT4nhYTBI=";
  };

  cargoLock = {
    lockFile = ./Cargo.lock;
  };

  postPatch = ''
    ln -s ${cargoLock.lockFile} Cargo.lock
  '';

  nativeBuildInputs = [
    pkg-config
  ];

  buildInputs =
    [
      openssl
    ]
    ++ lib.optionals stdenv.isDarwin [
      darwin.apple_sdk.frameworks.AppKit
      darwin.apple_sdk.frameworks.CoreGraphics
      darwin.apple_sdk.frameworks.Security
      darwin.apple_sdk.frameworks.SystemConfiguration
    ];

  doCheck = false;

  meta = {
    description = "Probe is an AI-friendly, fully local, semantic code search engine which which works with for large codebases. The final missing building block for next generation of AI coding tools";
    homepage = "https://github.com/buger/probe";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ meain ];
    mainProgram = "probe";
  };
}
