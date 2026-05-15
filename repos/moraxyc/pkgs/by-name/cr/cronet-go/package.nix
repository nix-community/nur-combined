{
  lib,
  stdenvNoCC,
  symlinkJoin,
  fetchurl,
  buildPackages,
  apple-sdk_15,
  darwin,
  ninja,
  python3,
  xcbuild,
  llvmPackages ? buildPackages.llvmPackages,

  sources,
  source ? sources.cronet-go,

  withPgo ? stdenvNoCC.hostPlatform == stdenvNoCC.buildPlatform,
}:
let
  llvmPgoPackageStr = "llvmPackages_22";
  llvm = if withPgo then buildPackages.${llvmPgoPackageStr} else llvmPackages;
  nativeLlvm =
    if withPgo then
      buildPackages.buildPackages.${llvmPgoPackageStr}
    else
      buildPackages.buildPackages.llvmPackages;
  isCrossLinux =
    stdenvNoCC.hostPlatform.isLinux && stdenvNoCC.hostPlatform != stdenvNoCC.buildPlatform;
  chromiumLinuxTargetTriples = {
    "i686-unknown-linux-gnu" = "i386-unknown-linux-gnu";
    "aarch64-unknown-linux-gnu" = "aarch64-linux-gnu";
    "armv7l-unknown-linux-gnueabihf" = "arm-linux-gnueabihf";
    "armv6l-unknown-linux-gnueabihf" = "arm-linux-gnueabihf";
    "mipsel-unknown-linux-gnu" = "mipsel-linux-gnu";
    "mips64el-unknown-linux-gnuabi64" = "mips64el-linux-gnuabi64";
    "riscv64-unknown-linux-gnu" = "riscv64-linux-gnu";
    "loongarch64-unknown-linux-gnu" = "loongarch64-linux-gnu";
  };
  supportedPlatforms = [
    "x86_64-linux"
    "aarch64-linux"
    "i686-linux"
    "armv7l-linux"
    "armv6l-linux"
    "loongarch64-linux"
    "mipsel-linux"
    "mips64el-linux"
    "riscv64-linux"
    "x86_64-darwin"
    "aarch64-darwin"
  ];
  pgoProfiles = lib.mapAttrs (
    _: v:
    fetchurl {
      name = v.name;
      url = "https://storage.googleapis.com/chromium-optimization-profiles/pgo_profiles/${v.name}";
      hash = v.hash;
    }
  ) (lib.importJSON ./pgo.json);

in
stdenvNoCC.mkDerivation (finalAttrs: {
  inherit (source) pname version src;

  postPatch = ''
    substituteInPlace naiveproxy/src/build/config/compiler/BUILD.gn \
      --replace-fail 'cflags += [ "-fno-lifetime-dse" ]' '# cflags += [ "-fno-lifetime-dse" ]' \
      --replace-fail '"-fsanitize-ignore-for-ubsan-feature=array-bounds"' '# "-fsanitize-ignore-for-ubsan-feature=array-bounds"' \
      --replace-fail '"-fsanitize-ignore-for-ubsan-feature=return"' '# "-fsanitize-ignore-for-ubsan-feature=return"' \
      --replace-fail '"-Wno-unsafe-buffer-usage-in-static-sized-array"' '# "-Wno-unsafe-buffer-usage-in-static-sized-array"'
  ''
  + lib.optionalString (isCrossLinux && finalAttrs.passthru.chromiumLinuxTargetTriple != null) ''
    substituteInPlace naiveproxy/src/build/config/compiler/BUILD.gn \
      --replace-warn '--target=${finalAttrs.passthru.chromiumLinuxTargetTriple}' '--target=${stdenvNoCC.hostPlatform.config}'
  ''
  + lib.optionalString stdenvNoCC.hostPlatform.isDarwin ''
    patchShebangs naiveproxy/src/build/toolchain/apple/linker_driver.py

    substituteInPlace naiveproxy/src/build/config/mac/BUILD.gn \
      --replace-fail 'common_mac_flags = []' 'common_mac_flags = [ "-I${lib.getInclude darwin.libresolv}/include" ]'
  ''
  + lib.optionalString withPgo ''
    mkdir -p naiveproxy/src/chrome/build/pgo_profiles
    cp ${finalAttrs.passthru.pgoProfile} naiveproxy/src/chrome/build/pgo_profiles/${finalAttrs.passthru.pgoProfile.name}
  '';

  outputs = [
    "out"
    "dev"
    "static"
  ];

  nativeBuildInputs = [
    llvm.bintools
    ninja
    python3
  ]
  ++ lib.optional stdenvNoCC.hostPlatform.isDarwin xcbuild;

  buildInputs = lib.optional stdenvNoCC.hostPlatform.isDarwin apple-sdk_15;

  patches = lib.optional isCrossLinux ./chromium-unbundle-cross.patch;

  env = {
    CRONET_GO_CLANG_BASE_PATH = finalAttrs.passthru.clangBasePath.outPath;
    CRONET_GO_ENABLE_PGO = lib.optionalString withPgo "1";
  }
  // lib.optionalAttrs isCrossLinux {
    CC = lib.getExe' finalAttrs.passthru.clangBasePath "${llvm.stdenv.cc.targetPrefix}cc";
    CXX = lib.getExe' finalAttrs.passthru.clangBasePath "${llvm.stdenv.cc.targetPrefix}c++";
    AR = lib.getExe' llvm.bintools "${llvm.stdenv.cc.targetPrefix}ar";
    NM = lib.getExe' llvm.bintools "${llvm.stdenv.cc.targetPrefix}nm";
    READELF = lib.getExe' llvm.bintools "${llvm.stdenv.cc.targetPrefix}readelf";
    BUILD_CC = lib.getExe' nativeLlvm.stdenv.cc "cc";
    BUILD_CXX = lib.getExe' nativeLlvm.stdenv.cc "c++";
    BUILD_AR = lib.getExe' nativeLlvm.bintools "ar";
    BUILD_NM = lib.getExe' nativeLlvm.bintools "nm";
    BUILD_READELF = lib.getExe' nativeLlvm.bintools "readelf";
    USE_UNBUNDLE_TOOLCHAIN = "1";
  };

  buildPhase = ''
    runHook preBuild

    ${lib.getExe finalAttrs.passthru.build-naive} build -t ${finalAttrs.passthru.goTarget}
    ${lib.getExe finalAttrs.passthru.build-naive} package --local -t ${finalAttrs.passthru.goTarget}
    ${lib.getExe finalAttrs.passthru.build-naive} package -t ${finalAttrs.passthru.goTarget}

    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall

    mkdir -p $out
  ''
  + lib.optionalString stdenvNoCC.hostPlatform.isLinux ''
    install -Dm755 lib/*/libcronet${stdenvNoCC.hostPlatform.extensions.sharedLibrary} \
      $out/lib/libcronet${stdenvNoCC.hostPlatform.extensions.sharedLibrary}
  ''
  + ''
    install -Dm644 lib/*/libcronet.a $static/lib/libcronet.a

    mkdir -p $dev/include/cronet-go $dev/share/cronet-go/go
    install -Dm644 include/*.h -t $dev/include/cronet-go
    install -Dm644 include_cgo.go lib/*/*.go lib/*/go.mod -t $dev/share/cronet-go/go

    runHook postInstall
  '';

  passthru = {
    # nix-update auto -u
    updateScript = ./update.sh;
    build-naive = buildPackages.callPackage ./build-naive.nix {
      source = buildPackages.sources.cronet-go;
    };
    clangBasePath = symlinkJoin {
      name = "llvmCcAndBintools";
      paths = [
        llvm.llvm
        llvm.stdenv.cc
      ];
    };
    chromiumLinuxTargetTriple = chromiumLinuxTargetTriples.${stdenvNoCC.hostPlatform.config} or null;
    goTarget = "${stdenvNoCC.hostPlatform.go.GOOS}/${stdenvNoCC.hostPlatform.go.GOARCH}";
    pgoProfile =
      pgoProfiles.${
        if stdenvNoCC.hostPlatform.isDarwin then
          stdenvNoCC.hostPlatform.system
        else if stdenvNoCC.hostPlatform.isLinux then
          "any-linux"
        else
          throw "Unsupported system for PGO: ${stdenvNoCC.hostPlatform.system}"
      };
  };

  meta = {
    description = "Go bindings for naiveproxy";
    homepage = "https://github.com/SagerNet/cronet-go";
    license = lib.licenses.gpl3Plus;
    maintainers = with lib.maintainers; [ moraxyc ];
    platforms = supportedPlatforms;
  };
})
