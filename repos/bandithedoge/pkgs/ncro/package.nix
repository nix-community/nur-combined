{
  sources,

  clangStdenv,
  lib,
  rustPlatform,

  wild,
}:
rustPlatform.buildRustPackage.override { stdenv = clangStdenv; } {
  inherit (sources.ncro) pname src;
  version = lib.removePrefix "v" sources.ncro.version;
  cargoLock = sources.ncro.cargoLock."Cargo.lock";

  nativeBuildInputs = [ wild ];

  doCheck = false;

  env.RUSTFLAGS = "-Clinker=clang";

  meta = {
    description = "Lightweight HTTP proxy for optimizing Nix cache routes for fast access";
    homepage = "https://github.com/manic-systems/ncro";
    license = lib.licenses.eupl12;
    platforms = lib.platforms.unix;
    mainProgram = "ncro";
    maintainers = [ lib.maintainers.bandithedoge ];
  };
}
