{ pkgs, lib, ... }:

pkgs.rustPlatform.buildRustPackage {
  pname = "shpool-mux";
  version = "0.1.1";

  src = ./.;

  cargoLock.lockFile = ./Cargo.lock;
}
