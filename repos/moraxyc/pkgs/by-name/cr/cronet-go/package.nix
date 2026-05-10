{
  lib,
  stdenvNoCC,
  symlinkJoin,
  fetchurl,
  llvmPackages,
  buildPackages,
  apple-sdk_15,
  darwin,
  ninja,
  python3,
  xcbuild,

  sources,
  source ? sources.cronet-go,

  withPgo ? true,
}:
let
  nativeLlvm = buildPackages.buildPackages.llvmPackages;
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
in
stdenvNoCC.mkDerivation (finalAttrs: {
  inherit (source) pname version src;

  postPatch =
    let
      pgoProfile =
        finalAttrs.passthru.pgoProfiles.${
          if stdenvNoCC.hostPlatform.isDarwin then
            stdenvNoCC.hostPlatform.system
          else if stdenvNoCC.hostPlatform.isLinux then
            "any-linux"
          else
            throw "Unsupported system for PGO: ${stdenvNoCC.hostPlatform.system}"
        };
    in
    ''
      substituteInPlace naiveproxy/src/build/config/compiler/BUILD.gn \
        --replace-fail 'cflags += [ "-fno-lifetime-dse" ]' '# cflags += [ "-fno-lifetime-dse" ]' \
        --replace-fail '"-fsanitize-ignore-for-ubsan-feature=array-bounds"' '# "-fsanitize-ignore-for-ubsan-feature=array-bounds"' \
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
      cp ${pgoProfile} naiveproxy/src/chrome/build/pgo_profiles/${pgoProfile.name}
    '';

  outputs = [
    "out"
    "dev"
    "static"
  ];

  nativeBuildInputs = [
    buildPackages.llvmPackages.bintools
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
    CC = lib.getExe' finalAttrs.passthru.clangBasePath "${llvmPackages.stdenv.cc.targetPrefix}cc";
    CXX = lib.getExe' finalAttrs.passthru.clangBasePath "${llvmPackages.stdenv.cc.targetPrefix}c++";
    AR = lib.getExe' llvmPackages.bintools "${llvmPackages.stdenv.cc.targetPrefix}ar";
    NM = lib.getExe' llvmPackages.bintools "${llvmPackages.stdenv.cc.targetPrefix}nm";
    READELF = lib.getExe' llvmPackages.bintools "${llvmPackages.stdenv.cc.targetPrefix}readelf";
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
    # nix-update auto -s build-naive --override-filename pkgs/by-name/cr/cronet-go/build-naive.nix
    build-naive = buildPackages.callPackage ./build-naive.nix {
      source = buildPackages.sources.cronet-go;
    };
    clangBasePath = symlinkJoin {
      name = "llvmCcAndBintools";
      paths = [
        llvmPackages.llvm
        llvmPackages.stdenv.cc
      ];
    };
    chromiumLinuxTargetTriple = chromiumLinuxTargetTriples.${stdenvNoCC.hostPlatform.config} or null;
    goTarget = "${stdenvNoCC.hostPlatform.go.GOOS}/${stdenvNoCC.hostPlatform.go.GOARCH}";
    pgoProfiles = {
      aarch64-darwin = fetchurl {
        url = "https://storage.googleapis.com/chromium-optimization-profiles/pgo_profiles/chrome-mac-arm-7778-1777396490-28f3bd2de3e5897faaeffb39ece6068b821b4568-01697e67ebd6a170e23bf1503bbc0c3723275c1b.profdata";
        hash = "sha256-gsM4lTXXmAop3n+LGFW2pRwVtIkgp/LOLmaho1Lahhc=";
      };
      x86_64-darwin = fetchurl {
        url = "https://storage.googleapis.com/chromium-optimization-profiles/pgo_profiles/chrome-mac-7778-1777374771-bf7aebabe8057c6700aa75240777f8557acfd474-d8efa9b284bd43eccbaf67df2d4a1deaa3c39b89.profdata";
        hash = "sha256-gXmewWdgIDMfb8ujTQAoWaK4t3nabp4hXfPXsCxZi4M=";
      };
      any-linux = fetchurl {
        url = "https://storage.googleapis.com/chromium-optimization-profiles/pgo_profiles/chrome-linux-7778-1777374771-45dd5813b3332165d1d1cd33a478e0a7b948195e-d8efa9b284bd43eccbaf67df2d4a1deaa3c39b89.profdata";
        hash = "sha256-qRbwmZivUpte1ILYnFBusAbRBnv/YDaEoXd46LYeaCw=";
      };
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
