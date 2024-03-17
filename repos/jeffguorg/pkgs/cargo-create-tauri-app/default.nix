{ stdenv, rustPlatform, fetchCrate, sources, ... }:
let
  system = stdenv.targetPlatform.uname.system;
  src = sources.cargo-create-tauri-app;
in
rustPlatform.buildRustPackage {
  inherit (src) pname version;

  cargoLock = {
    lockFileContents = src."Cargo.lock";
  };

  src = src.src;
}
