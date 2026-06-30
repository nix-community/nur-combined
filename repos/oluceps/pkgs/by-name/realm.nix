{
  lib,
  makeRustPlatform,
  fenix,
  fetchurl,
  fetchgit,
  fetchFromGitHub,
  dockerTools,
  pkg-config,
  enableJemalloc ? true,
  jemalloc,
  cmake,
}:

let
  inherit (fenix.minimal) toolchain;
  sources = import ../../_sources/generated.nix {
    inherit
      fetchurl
      fetchgit
      fetchFromGitHub
      dockerTools
      ;
  };
  rustPlatform = (
    makeRustPlatform {
      cargo = toolchain;
      rustc = toolchain;
    }
  );
in
rustPlatform.buildRustPackage {
  inherit (sources.realm) pname version src;

  cargoLock = sources.realm.cargoLock."Cargo.lock";

  CFLAGS = "-Wno-error=stringop-overflow";

  buildInputs = lib.optional enableJemalloc jemalloc;

  buildFeatures = lib.optional enableJemalloc "jemalloc";

  nativeBuildInputs = [
    pkg-config
    rustPlatform.bindgenHook
    cmake
  ];

  meta = {
    description = "A simple, high performance relay, supporting both TCP and UDP";
    homepage = "https://github.com/zhboner/realm";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ oluceps ];
    mainProgram = "realm";
  };
}
