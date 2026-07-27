{
  sources,

  lib,
  rustPlatform,

  clangStdenv,
}:
rustPlatform.buildRustPackage.override { stdenv = clangStdenv; } {
  inherit (sources.nixtopsy) pname src;
  version = lib.removePrefix "v" sources.nixtopsy.version;
  cargoLock = sources.nixtopsy.cargoLock."Cargo.lock";

  env.RUSTFLAGS = "-Clinker=clang";

  meta = {
    description = "Interactively dissect your Nix closures";
    homepage = "https://github.com/manic-systems/nixtopsy";
    license = lib.licenses.mit;
    platforms = lib.platforms.unix;
    mainProgram = "nixtopsy";
    maintainers = [ lib.maintainers.bandithedoge ];
  };
}
