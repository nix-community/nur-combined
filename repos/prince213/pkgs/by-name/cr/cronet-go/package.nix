{
  lib,
  buildGoModule,
  fetchFromGitHub,
  replaceVars,
  stdenvNoCC,
  symlinkJoin,

  # nativeBuildInputs
  buildPackages,
  gn,
  ninja,
  python3,
  xcbuild,

  # buildInputs
  apple-sdk_15,
  darwin,
}:
let
  llvmCcAndBintools = symlinkJoin {
    name = "llvmCcAndBintools";
    paths = [
      buildPackages.rustc.llvmPackages.llvm
      buildPackages.rustc.llvmPackages.stdenv.cc
    ];
  };
in
stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "cronet-go";
  version = "150.0.7871.63-1-unstable-2026-07-31";

  __structuredAttrs = true;
  strictDeps = true;

  src = fetchFromGitHub {
    owner = "SagerNet";
    repo = "cronet-go";
    rev = "cfbca3ad7edb3f8c1bd78b4bcb7c4c1a1ae3d195";
    fetchSubmodules = true;
    hash = "sha256-zRT5pNwspqb69SbR20cw9wgihxSTX8uqwpx0IPZuLOg=";
  };

  patches = [
    ./cflags.patch
  ]
  ++ lib.optional stdenvNoCC.hostPlatform.isDarwin (
    replaceVars ./libresolv.patch {
      libresolv = lib.getInclude darwin.libresolv;
    }
  );

  postPatch = ''
    patchShebangs --build naiveproxy/src/build/toolchain/apple/linker_driver.py
  '';

  nativeBuildInputs = [
    buildPackages.rustc.llvmPackages.bintools
    ninja
    python3
  ]
  ++ lib.optional stdenvNoCC.hostPlatform.isDarwin xcbuild;

  buildInputs = lib.optional stdenvNoCC.hostPlatform.isDarwin apple-sdk_15;

  buildPhase = ''
    runHook preBuild

    ${lib.getExe finalAttrs.passthru.build-naive} build
    ${lib.getExe finalAttrs.passthru.build-naive} package --local
    ${lib.getExe finalAttrs.passthru.build-naive} package

    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall

    mkdir -p $out
    cp -r lib include include_cgo.go $out/

    runHook postInstall
  '';

  passthru = {
    build-naive = buildGoModule {
      pname = finalAttrs.pname + "-build-naive";
      inherit (finalAttrs) version src;
      vendorHash = "sha256-pyeE+JPuRQEjNzrF+o9jslBcBM1vruuL+I/DCIa2BG0=";
      patches = [
        (replaceVars ./build-naive.patch {
          gn = lib.getExe gn;
          clang_base_path = llvmCcAndBintools;
        })
      ];
      subPackages = [ "cmd/build-naive" ];
      meta.mainProgram = "build-naive";
    };
  };

  meta = {
    description = "Go bindings for naiveproxy";
    branch = "dev";
    homepage = "https://github.com/SagerNet/cronet-go";
    license = lib.licenses.gpl3Plus;
    maintainers = with lib.maintainers; [ prince213 ];
    platforms = lib.platforms.darwin ++ lib.platforms.linux;
  };
})
