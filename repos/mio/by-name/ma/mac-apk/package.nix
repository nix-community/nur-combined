{
  lib,
  clangStdenv,
  fetchFromGitHub,
  runCommand,
  cacert,
  curl,
  cmake,
  swift,
  apple-sdk_27,
  openjdk21,
  capstone,
  libpng,
  libvpx,
  sqlite,
  zlib,
  aapt,
  zip,
  unzip,
  python3,
  coreutils,
  darwin,
  rsync,
  writeShellApplication,
  nix-update-script,
}:

let
  version = "1.0.2404";

  # Android 16 (API 36) AOSP frameworks/base/core/res source tree (Apache-2.0).
  # Google's gitiles +archive tarballs embed request-time timestamps in gzip/tar
  # headers, so we unpack inside a fixed-output derivation whose NAR hash only
  # hashes the extracted directory contents (timestamps stripped by tar).
  aospCoreResSrc =
    runCommand "aosp-frameworks-base-core-res-android-16.0.0_r2"
      {
        nativeBuildInputs = [
          cacert
          curl
        ];
        outputHashAlgo = "sha256";
        outputHashMode = "recursive";
        outputHash = "sha256-od9VaH/N0O/0+cjmjjTRYuCoZIIHXbQsqVnjSGQwYpE=";
      }
      ''
        mkdir -p "$out"
        curl -fsSL \
          "https://android.googlesource.com/platform/frameworks/base/+archive/refs/tags/android-16.0.0_r2/core/res.tar.gz" \
          | tar -xzf - -C "$out"
      '';

  relinkNixDeps = writeShellApplication {
    name = "relink-nix-deps";
    runtimeInputs = [
      darwin.cctools
      darwin.sigtool
    ];
    text = ''
      set -euo pipefail

      project_dir="$(cd "$(dirname "$0")/.." && pwd)"
      app="$project_dir/build/Mac.apk.app"
      bin="$app/Contents/bin"

      rewrite_dependency() {
        target="$1"
        pattern="$2"
        replacement="$3"
        old="$(otool -L "$target" | awk -v pattern="$pattern" '$1 ~ pattern { print $1; exit }')"
        if [ -n "$old" ] && [ "$old" != "$replacement" ]; then
          chmod u+w "$target"
          install_name_tool -change "$old" "$replacement" "$target"
        fi
      }

      for target in "$bin/libmacapk-bionic-shim.dylib" "$bin/macapk-translator"; do
        rewrite_dependency "$target" 'libcapstone' '@rpath/libcapstone.5.dylib'
        codesign --force --sign - --timestamp=none "$target"
      done

      png="$bin/libpng16.16.dylib"
      rewrite_dependency "$png" 'libz(\\.|$)' '/usr/lib/libz.1.dylib'
      codesign --force --sign - --timestamp=none "$png"
    '';
  };

  dittoWrapper = writeShellApplication {
    name = "ditto";
    runtimeInputs = [ coreutils ];
    text = ''
      set -euo pipefail
      src="$1"
      dst="$2"
      if [ -d "$src" ]; then
        rm -rf "$dst"
        cp -pR "$src" "$dst"
      else
        mkdir -p "$(dirname "$dst")"
        rm -f "$dst"
        cp -pf "$src" "$dst"
      fi
    '';
  };

  codesignWrapper = writeShellApplication {
    name = "codesign";
    text = ''
      exec /usr/bin/codesign "$@"
    '';
  };

  plutilWrapper = writeShellApplication {
    name = "plutil";
    runtimeInputs = [ python3 ];
    text = ''
      exec python3 ${./files/plutil.py} "$@"
    '';
  };
in
clangStdenv.mkDerivation {
  pname = "mac-apk";
  inherit version;

  # Upstream's macOS 26 launcher uses SwiftUI macros supplied by the host
  # Xcode toolchain; nixpkgs' Swift SDK does not include their plugin.
  __noChroot = clangStdenv.hostPlatform.isDarwin;

  src = fetchFromGitHub {
    owner = "kksimp";
    repo = "Mac.apk";
    tag = "v${version}";
    hash = "sha256-y/XO7UYJ/gX8uK3YIb3hWNYVf4PleiC5TX3leE26fUw=";
  };

  dontUseCmakeConfigure = true;

  nativeBuildInputs = [
    cmake
    swift
    openjdk21
    aapt
    zip
    unzip
    python3
    darwin.sigtool
    darwin.cctools
    rsync
  ];

  buildInputs = [
    apple-sdk_27
    openjdk21
    capstone
    libpng
    libvpx
    sqlite
    zlib
  ];

  postPatch = ''
        patchShebangs scripts runtime/scripts debug
        substituteInPlace scripts/build_launcher.sh \
          --replace-warn '/usr/bin/env python3' 'python3' \
          --replace-warn 'mktemp -t macapk_bundle_audit' 'mktemp -t macapk_bundle_audit.XXXXXX' \
          --replace-warn 'swiftc ' 'swiftc -Xfrontend -disable-sandbox '
        substituteInPlace runtime/scripts/build.sh \
          --replace-warn '/usr/bin/python3' 'python3' \
          --replace-warn '/tmp/macapk_ent_err.txt' '"$TMPDIR/macapk_ent_err.txt"' \
          --replace-warn 'mktemp -t macapk_sync_audit' 'mktemp -t macapk_sync_audit.XXXXXX' \
          --replace-warn '[[ -f /opt/homebrew/opt/capstone/include/capstone/capstone.h ]]' '[[ -f "''${CAPSTONE_ROOT:-/opt/homebrew/opt/capstone}/include/capstone/capstone.h" ]]'
        substituteInPlace scripts/gen_third_party_notices.sh \
          --replace-warn 'CAP_KEG="$(ls -d /opt/homebrew/Cellar/capstone/*/ 2>/dev/null | sort -V | tail -1)"' 'CAP_KEG="$( (ls -d /opt/homebrew/Cellar/capstone/*/ 2>/dev/null || true) | sort -V | tail -1 )"' \
          --replace-warn 'PNG_KEG="$(ls -d /opt/homebrew/Cellar/libpng/*/ 2>/dev/null | sort -V | tail -1)"' 'PNG_KEG="$( (ls -d /opt/homebrew/Cellar/libpng/*/ 2>/dev/null || true) | sort -V | tail -1 )"' \
          --replace-warn '2>/dev/null && pwd -P' '2>/dev/null && pwd -P || true' \
          --replace-warn '$(keg brotli)/LICENSE' '$(first "$(keg brotli)/LICENSE")'
        substituteInPlace scripts/relink_bundle_deps.sh \
          --replace-warn 'CAPSTONE_SRC="/opt/homebrew/opt/capstone/lib/libcapstone.5.dylib"' 'CAPSTONE_SRC="''${CAPSTONE_SRC:-''${CAPSTONE_ROOT:-/opt/homebrew/opt/capstone}/lib/libcapstone.5.dylib}"' \
          --replace-warn 'LIBPNG_SRC="/opt/homebrew/opt/libpng/lib/libpng16.16.dylib"' 'LIBPNG_SRC="''${LIBPNG_SRC:-''${LIBPNG_ROOT:-/opt/homebrew/opt/libpng}/lib/libpng16.16.dylib}"'
        cp ${relinkNixDeps}/bin/relink-nix-deps scripts/relink_nix_deps.sh
        substituteInPlace scripts/relink_bundle_deps.sh \
          --replace-warn 'echo "  relink_bundle_deps.sh done"' 'bash "$PROJECT_DIR/scripts/relink_nix_deps.sh"
    echo "  relink_bundle_deps.sh done"'

        # Keep the upstream source behavior while pointing optional native libraries
        # at the declared Nix inputs instead of Homebrew paths.
        substituteInPlace runtime/CMakeLists.txt \
          --replace-fail 'set(LIBVPX_ROOT "/opt/homebrew/opt/libvpx")' 'set(LIBVPX_ROOT "$ENV{LIBVPX_ROOT}")' \
          --replace-warn 'EXISTS "''${LIBVPX_ROOT}/include/vpx/vpx_decoder.h"' 'EXISTS "$ENV{LIBVPX_INCLUDE_DIR}/vpx/vpx_decoder.h"' \
          --replace-warn 'target_include_directories(macapk-runtime PRIVATE "''${LIBVPX_ROOT}/include")' 'target_include_directories(macapk-runtime PRIVATE "$ENV{LIBVPX_INCLUDE_DIR}")'
        substituteInPlace runtime/translator/CMakeLists.txt \
          --replace-warn 'set(CAPSTONE_ROOT "/opt/homebrew/opt/capstone")' 'set(CAPSTONE_ROOT "$ENV{CAPSTONE_ROOT}")' \
          --replace-warn 'set(LIBPNG_ROOT "/opt/homebrew/opt/libpng")' 'set(LIBPNG_ROOT "$ENV{LIBPNG_ROOT}")' \
          --replace-warn 'EXISTS "''${LIBPNG_ROOT}/include/png.h"' 'EXISTS "$ENV{LIBPNG_INCLUDE_DIR}/png.h"'

        mkdir -p "$TMPDIR/macapk-nix-bin"
        cp ${dittoWrapper}/bin/ditto "$TMPDIR/macapk-nix-bin/ditto"
        cp ${codesignWrapper}/bin/codesign "$TMPDIR/macapk-nix-bin/codesign"
        cp ${plutilWrapper}/bin/plutil "$TMPDIR/macapk-nix-bin/plutil"
        export PATH="$TMPDIR/macapk-nix-bin:$PATH"
  '';

  buildPhase = ''
    runHook preBuild

    export HOME="$TMPDIR/home"
    mkdir -p "$HOME"
    export PATH="$TMPDIR/macapk-nix-bin:$PATH"

    if [ -z "''${MACAPK_USE_NIX_SDK:-}" ] && [ -d /Applications/Xcode.app ]; then
      export DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer
      export PATH="$DEVELOPER_DIR/Toolchains/XcodeDefault.xctoolchain/usr/bin:$PATH"
      export SDKROOT="$(xcrun --sdk macosx --show-sdk-path)"
    fi

    export JAVA_HOME="${openjdk21}"
    export MACAPK_JDK_HOME="${openjdk21}"
    mkdir -p "$TMPDIR/capstone/lib"
    capstoneDylib="$(find "${capstone}/lib" -maxdepth 1 -name 'libcapstone.*.dylib' -print -quit)"
    test -n "$capstoneDylib"
    ln -s "$capstoneDylib" "$TMPDIR/capstone/lib/libcapstone.5.dylib"
    ln -s "$capstoneDylib" "$TMPDIR/capstone/lib/libcapstone.dylib"
    ln -s "${capstone}/include" "$TMPDIR/capstone/include"
    export CAPSTONE_ROOT="$TMPDIR/capstone"
    export CAPSTONE_SRC="$capstoneDylib"
    export LIBPNG_SRC="${libpng.out}/lib/libpng16.16.dylib"
    mkdir -p "$TMPDIR/libpng/include" "$TMPDIR/libpng/lib"
    cp -R "${libpng.dev}/include/." "$TMPDIR/libpng/include/"
    cp -R "${libpng.out}/lib/." "$TMPDIR/libpng/lib/"
    export LIBPNG_ROOT="$TMPDIR/libpng"
    export LIBPNG_INCLUDE_DIR="$TMPDIR/libpng/include"
    export CXXFLAGS="-I$TMPDIR/libpng/include ''${CXXFLAGS:-}"
    export LIBVPX_ROOT="${libvpx.out}"
    export LIBVPX_INCLUDE_DIR="${libvpx.dev}/include"
    export AAPT2="${aapt}/bin/aapt2"
    export MACAPK_NO_SDK_FALLBACK=1
    export MACAPK_NO_BUNDLE_SYNC=1
    export MACAPK_BUILD_STAMP="261029.0000"

    # Pre-populate the AOSP core/res source tree so build_framework_res.sh
    # builds framework-res-api36.apk offline using aapt2.
    mkdir -p thirdparty/framework-res/work-android-16.0.0_r2/src
    cp -R "${aospCoreResSrc}/." thirdparty/framework-res/work-android-16.0.0_r2/src/
    chmod -R u+w thirdparty/framework-res/work-android-16.0.0_r2/src
    bash scripts/build_framework_res.sh --api 36 --tag android-16.0.0_r2 --version-name 16

    # Build the runtime, JNI bridges, Skia Metal bridge, ARM32->arm64 translator, and Bionic shim.
    bash runtime/scripts/build.sh

    # Build the Mac.apk.app launcher bundle, appstub, installhelper, Location helper, and staged JRE.
    bash scripts/build_launcher.sh

    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall

    mkdir -p "$out/Applications" "$out/bin"
    cp -pR build/Mac.apk.app "$out/Applications/Mac.apk.app"

    ln -s "$out/Applications/Mac.apk.app/Contents/MacOS/MacApk" "$out/bin/mac-apk"
    ln -s "$out/Applications/Mac.apk.app/Contents/Resources/macapk-runtime" "$out/bin/macapk-runtime"
    ln -s "$out/Applications/Mac.apk.app/Contents/bin/macapk-translator" "$out/bin/macapk-translator"
    ln -s "$out/Applications/Mac.apk.app/Contents/bin/macapk-installhelper" "$out/bin/macapk-installhelper"

    runHook postInstall
  '';

  # Mac.apk.app is already relinked to @rpath and ad-hoc signed with hardened
  # runtime + JIT/x18 entitlements during build_launcher.sh; Nix's Darwin fixup
  # hooks would rewrite load commands or strip signatures and invalidate the
  # x18/JIT entitlements.
  dontFixup = true;

  passthru.updateScript = writeShellApplication {
    name = "update-mac-apk";
    text = ''
      export UPDATE_NIX_ATTR_PATH="mac-apk"
      exec ${lib.escapeShellArgs (nix-update-script { })} "$@"
    '';
  };

  meta = {
    description = "Run Android APKs natively on Apple Silicon macOS (Dalvik/DEX-to-JVM + ARM64/ARM32 Bionic-to-Darwin + GLES-to-Metal)";
    homepage = "https://github.com/kksimp/Mac.apk";
    license = with lib.licenses; [
      asl20
      bsd3
      #gpl2ClasspathPlus
      mit
    ];
    mainProgram = "mac-apk";
    platforms = [ "aarch64-darwin" ];
  };
}
