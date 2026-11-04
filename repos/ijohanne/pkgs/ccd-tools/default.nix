{ lib, rustPlatform }:
rustPlatform.buildRustPackage {
  pname = "ccd-tools";
  version = "0.1.0";

  src = lib.cleanSourceWith {
    src = ./src;
    filter = path: type: lib.cleanSourceFilter path type && baseNameOf path != "target";
  };
  cargoLock.lockFile = ./src/Cargo.lock;

  meta = {
    description = "Concordium account status reports from CCDExplorer";
    homepage = "https://github.com/ijohanne/nur-packages";
    license = lib.licenses.mit;
    mainProgram = "ccd-status";
    platforms = lib.platforms.unix;
  };
}
