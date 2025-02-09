{ lib, rustPlatform }: rustPlatform.buildRustPackage {
  pname = "printargs";
  version = "0.1.0";
  src = lib.cleanSource ./.;
  cargoLock.lockFile = ./Cargo.lock;
}
