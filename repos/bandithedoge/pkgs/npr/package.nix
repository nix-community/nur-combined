{
  sources,

  lib,
  rustPlatform,
}:
rustPlatform.buildRustPackage {
  inherit (sources.npr) pname src;
  version = sources.npr.date;
  cargoLock = sources.npr.cargoLock."Cargo.lock";

  meta = {
    description = "Pull request tracker for Nixpkgs";
    homepage = "https://github.com/manic-systems/npr";
    license = lib.licenses.gpl3Plus;
    platforms = lib.platforms.unix;
    mainProgram = "npr";
    maintainers = [ lib.maintainers.bandithedoge ];
  };
}
