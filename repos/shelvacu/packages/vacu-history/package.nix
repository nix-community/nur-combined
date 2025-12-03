{
  lib,

  rustPlatform,
  sqlite,
}:
rustPlatform.buildRustPackage {
  pname = "vacu-history";
  version = "1.0.0";

  src = ./.;

  cargoLock.lockFile = ./Cargo.lock;

  buildInputs = [ sqlite ];

  meta = {
    description = "program to store bash command history in a sqlite file";
    license = [ lib.licenses.mit ];
    sourceProvenance = [ lib.sourceTypes.fromSource ];
    mainProgram = "vacu-history";
    platforms = lib.platforms.all;
  };
}
