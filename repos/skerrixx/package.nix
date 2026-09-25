{ lib, rustPlatform }:

rustPlatform.buildRustPackage {
  pname = "rfetch";
  version = "1.1.0";

  src = ./.;

  cargoLock = {
    lockFile = ./Cargo.lock;
  };

  meta = {
    description = "A simple and convenient fetch tool written in Rust";
    homepage = "https://github.com/skerrixx/rfetch";
    license = lib.licenses.gpl3Plus;
    mainProgram = "rfetch";
    platforms = lib.platforms.linux;
  };
}
