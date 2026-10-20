{ lib, applyPatches, fetchFromGitHub, rustPlatform, fetchurl, wtype }:
let
  pin = lib.importJSON ../codex-desktop/sources.json;
  upstream = fetchFromGitHub { inherit (pin.backend) owner repo rev hash; };
  buildRustPackage = rustPlatform.buildRustPackage.override {
    importCargoLock = rustPlatform.importCargoLock.override {
      fetchurl = args: fetchurl (args // {
        url = lib.replaceStrings
          [ "https://crates.io/api/v1/crates" ]
          [ "https://static.crates.io/crates" ]
          args.url;
      });
    };
  };
  backendSource = applyPatches {
    name = "codex-desktop-linux-niri-source";
    src = upstream;
    patches = map (name: ./patches + "/${name}") pin.backendPatches;
  };
in
buildRustPackage {
  pname = "codex-computer-use-niri";
  version = pin.backendVersion;
  src = backendSource;
  # Local lock metadata avoids importing the patched source during evaluation.
  cargoLock.lockFile = ./Cargo.lock;
  cargoBuildFlags = [ "-p" "codex-computer-use-linux" "--bin" "codex-computer-use-linux" ];
  cargoTestFlags = [ "-p" "codex-computer-use-linux" "--bin" "codex-computer-use-linux" ];
  doCheck = true;
  COMPUTER_USE_WTYPE_EXECUTABLE = "${wtype}/bin/wtype";
  passthru = { inherit backendSource; };
  meta = {
    description = "Native Codex Computer Use backend patched for niri";
    homepage = "https://github.com/lihaoze123/niri-computer-use";
    license = lib.licenses.mit;
    mainProgram = "codex-computer-use-linux";
    platforms = [ "x86_64-linux" ];
  };
}
