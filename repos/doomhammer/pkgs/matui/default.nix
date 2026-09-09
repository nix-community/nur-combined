{
  source,
  lib,
  rustPlatform,
  pkg-config,
  ffmpeg,
  sqlite,
  openssl,
}:
let
  sharedDeps = [
    pkg-config
  ];
in
rustPlatform.buildRustPackage {
  inherit (source)
    pname
    version
    src
    ;

  buildInputs = [ openssl ];

  nativeBuildInputs = sharedDeps ++ [
    ffmpeg
    sqlite
  ];

  cargoLock = source.cargoLock."Cargo.lock";

  meta = {
    description = "A very opinionated Matrix TUI.";
    homepage = "https://github.com/pkulak/matui";
    license = lib.licenses.gpl2;
  };
}
