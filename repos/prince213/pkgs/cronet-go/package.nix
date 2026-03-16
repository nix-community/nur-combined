{
  apple-sdk_15,
  buildGoModule,
  buildPackages,
  darwin,
  fetchFromGitHub,
  gn,
  lib,
  ninja,
  python3,
  replaceVars,
  stdenvNoCC,
  symlinkJoin,
  xcbuild,
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
  version = "145.0.7632.159-unstable-2026-03-09";

  src = fetchFromGitHub {
    owner = "SagerNet";
    repo = "cronet-go";
    rev = "ea7cd33752aed62603775af3df946c1b83f4b0b3";
    fetchSubmodules = true;
    hash = "sha256-adLSUuw2IpiB/o5HPUkoSanSN5TnE776oBDEcNoYnHM=";
  };

  patches = lib.optional stdenvNoCC.hostPlatform.isDarwin (
    replaceVars ./libresolv.patch {
      libresolv = lib.getInclude darwin.libresolv;
    }
  );

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
      vendorHash = "sha256-tVIKTznnducPfATK151TpC3UV2U852TyclBTSgh/H6U=";
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
