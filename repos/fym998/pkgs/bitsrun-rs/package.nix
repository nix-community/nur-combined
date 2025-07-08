{
  lib,
  rustPlatform,
  fetchFromGitHub,
  stdenv,
  darwin,
}:
rustPlatform.buildRustPackage rec {
  pname = "bitsrun-rs";
  version = "0.5.0";

  src = fetchFromGitHub {
    owner = "spencerwooo";
    repo = "bitsrun-rs";
    rev = "v${version}";
    hash = "sha256-ga32t5D0DnlhVfSUGj73ZpVG+MsPPgbWLJOqa73wo9s=";
  };

  cargoLock = {
    lockFile = ./Cargo.lock;
  };

  patches = [ ./remove-qemu-runner.patch ];

  postPatch = ''
    ln -s ${./Cargo.lock} Cargo.lock
  '';

  buildInputs = lib.optionals stdenv.isDarwin [
    darwin.apple_sdk.frameworks.Security
    darwin.apple_sdk.frameworks.SystemConfiguration
  ];

  meta = {
    description = "A headless login / logout CLI for gateway (10.0.0.55) at BIT, now in Rust. 北京理工大学 10.0.0.55 校园网登录登出的 Rust 实现";
    homepage = "https://github.com/spencerwooo/bitsrun-rs";
    license = lib.licenses.mit;
    mainProgram = "bitsrun";
  };
}
