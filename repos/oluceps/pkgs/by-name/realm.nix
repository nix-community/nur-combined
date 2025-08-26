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
  version = "2.9.1";
  src = fetchFromGitHub {
    owner = "zhboner";
    repo = "realm";
    rev = "v${version}";
    hash = "sha256-6nN+P1nyuWxk6UtIv40/r58vpXHckfHJ3hOqiiLrp/I=";
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
  cargoHash = "sha256-u3CCur5QRgZXU2YQw0gc8JkycVyfIttu8ett5c1RJqg=";

  meta.mainProgram = "realm";
}
