{
  lib,
  fetchFromGitHub,
  fenix,
  makeRustPlatform,
  pkg-config,
  enableJemalloc ? true,
  rust-jemalloc-sys,
  cmake,
}:
let
  inherit (fenix.minimal) toolchain;
  rustPlatform = (
    makeRustPlatform {
      cargo = toolchain;
      rustc = toolchain;
    }
  );
in
rustPlatform.buildRustPackage rec {
  pname = "realm";
  version = "2.9.2-2";
  src = fetchFromGitHub {
    owner = "zhboner";
    repo = "realm";
    rev = "v${version}";
    hash = "sha256-TWtLwGjL0nOK6NYxG+Q22hS9PGq9igokNPjUxRLiPl8=";
  };

  CFLAGS = "-Wno-error=stringop-overflow";

  builtInputs = [
  ]
  ++ lib.optional enableJemalloc rust-jemalloc-sys;

  buildFeatures = lib.optional enableJemalloc "jemalloc";

  nativeBuildInputs = [
    pkg-config
    rustPlatform.bindgenHook
    cmake
  ];
  cargoHash = "sha256-RRqOfKbZ6tATYW55EJd1r2zQA0Vt463eGn1fuNO8k5M=";

  meta.mainProgram = "realm";
}
