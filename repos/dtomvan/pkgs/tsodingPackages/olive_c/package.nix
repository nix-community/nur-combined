{
  glibc_multi,
  nob_h,
  llvmPackages_19,
  lib,
  fetchFromGitHub,
  buildNobPackage,
  replaceVars,
  SDL2,
  sdlSupport ? true,

  nix-update-script,
}:
let
  llvmPackages = llvmPackages_19;
  cc = llvmPackages.clang;
in
(buildNobPackage.override { inherit (llvmPackages_19) stdenv; }) {
  pname = "olive.c";
  version = "0-unstable-2025-03-03";

  src = fetchFromGitHub {
    owner = "tsoding";
    repo = "olive.c";
    rev = "d770d9c995010dbb1dbbce262d01502076c63814";
    hash = "sha256-cH7e2fXhUQU27pp2iCMmWtsQk7mrMkI5MTrin/pYL34=";
  };

  buildInputs = lib.optional sdlSupport SDL2;
  nativeBuildInputs = [ llvmPackages.bintools ];

  patches = [
    ./use-nix-nob.patch
    # we need this patch, because we need to be using unwrapped clang for the
    # wasm32 target. This is a hassle, but is caused by a quirk in
    # cc-wrapper.sh
    (replaceVars ./use-different-wasm32-compiler.patch {
      CLANG_WASM = "clang-19";
      GLIBC = glibc_multi.dev;
      CLANG = cc.passthru.cc.lib;
      NOB_H = nob_h;
    })
  ];

  nobArgs = [ "tools" ];

  doCheck = sdlSupport;
  # we call nob once more to build assets and tests, which fail without SDL2
  checkPhase = "./nob && ./build/test run";

  postInstall = ''
    mkdir -p $out/bin
    cp olive.c $out/olive.c

    cp build/{demos,tools}/* $out/bin

    mkdir -p $out/wasm
    mv $out/bin/*.wasm $out/wasm

    cp -r build/assets $out

    cp -r js index.html $out
  '';

  passthru.updateScript = nix-update-script { extraArgs = [ "--version=branch" ]; };

  meta = {
    description = "Simple 2D Graphics Library for C";
    homepage = "https://github.com/tsoding/olive.c";
    license = lib.licenses.mit;
  };
}
