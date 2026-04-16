{ stdenv, rustPlatform, pkgs, sources, ... }:
let
  create-tauri-app = sources.create-tauri-app;
in
rustPlatform.buildRustPackage rec {
  pname = create-tauri-app.pname;
  version = create-tauri-app.version;

  cargoLock = create-tauri-app.cargoLock."Cargo.lock";

  src = create-tauri-app.src;
}
