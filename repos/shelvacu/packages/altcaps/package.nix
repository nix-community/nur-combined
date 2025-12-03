{ rustPlatform, lib }:
rustPlatform.buildRustPackage {
  pname = "altcaps";
  version = "1.0.0";

  src = ./.;

  cargoLock.lockFile = ./Cargo.lock;

  meta = {
    description = "CLI for taking some text and aLtErNaTiNg CaPiTaLiZaTiOn for dramatic effect";
    mainProgram = "altcaps";
    platforms = lib.platforms.all;
    license = [ lib.licenses.mit ];
    sourceProvenance = [ lib.sourceTypes.fromSource ];
  };
}
