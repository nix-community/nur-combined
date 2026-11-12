{
  lib,
  clangStdenv,
  fetchFromGitHub,
  runCommand,
  cacert,
  curl,
  cmake,
  swift,
  apple-sdk_15,
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
  darwin,
  rsync,
  writeShellApplication,
  nix-update-script,
}:

let
  version = "1.0.2379";
  # Commit of the upstream v1.0.2379 release tag.
  rev = "153968c83524c40abaef96cd35ab5d73cbbbc3d9";

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
in
clangStdenv.mkDerivation {
  pname = "mac-apk";
  inherit version;

  src = fetchFromGitHub {
    owner = "kksimp";
    repo = "Mac.apk";
    inherit rev;
    hash = "sha256-3dj7MzVlK0MKdXeyacYFBkMpCqKKOfGu/eDyL7CtJw4=";
  };

  patches = [
    ./macos15-nix.patch
    ./stack-chk-fail-no-recovery-frame.patch
  ];

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
    apple-sdk_15
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
      --replace-fail '/usr/bin/env python3' 'python3' \
      --replace-fail 'mktemp -t macapk_bundle_audit' 'mktemp -t macapk_bundle_audit.XXXXXX'
    substituteInPlace runtime/scripts/build.sh \
      --replace-fail '/tmp/macapk_ent_err.txt' '"$TMPDIR/macapk_ent_err.txt"' \
      --replace-fail 'mktemp -t macapk_sync_audit' 'mktemp -t macapk_sync_audit.XXXXXX'

    # Provide a pure-shell 'ditto' replacement in PATH for the Nix Darwin sandbox
    # (where /usr/bin/ditto is not available).
    mkdir -p "$TMPDIR/bin"
    cat > "$TMPDIR/bin/ditto" <<'EOF'
    #!${clangStdenv.shell}
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
    EOF
    chmod +x "$TMPDIR/bin/ditto"

    # Wrap sigtool's codesign so flags only supported by Apple's /usr/bin/codesign
    # (--options runtime, --timestamp=none, --verify, and .app bundle directories)
    # work seamlessly inside the Nix Darwin sandbox.
    cat > "$TMPDIR/bin/codesign" <<'EOF'
    #!${clangStdenv.shell}
    set -euo pipefail
    mode="sign"
    args=()
    files=()
    while [ $# -gt 0 ]; do
      case "$1" in
        --verify|-v|-vv)
          mode="verify"
          shift
          ;;
        --strict|--deep|--timestamp|--timestamp=*)
          shift
          ;;
        --options)
          shift 2
          ;;
        --options=*)
          shift
          ;;
        -s|--sign|-i|--identifier|--entitlements)
          args+=("$1" "$2")
          shift 2
          ;;
        -f|--force)
          args+=("-f")
          shift
          ;;
        -*)
          shift
          ;;
        *)
          files+=("$1")
          shift
          ;;
      esac
    done
    if [ "$mode" = "verify" ]; then
      exit 0
    fi
    real_files=()
    for f in "''${files[@]}"; do
      if [ -d "$f" ] && [ -d "$f/Contents/MacOS" ]; then
        for bin in "$f/Contents/MacOS"/*; do
          [ -f "$bin" ] && real_files+=("$bin")
        done
      elif [ -f "$f" ]; then
        real_files+=("$f")
      fi
    done
    if [ "''${#real_files[@]}" -eq 0 ]; then
      exit 0
    fi
    exec "${darwin.sigtool}/bin/codesign" "''${args[@]}" "''${real_files[@]}"
    EOF
    chmod +x "$TMPDIR/bin/codesign"

    # /usr/bin/plutil lives outside the build sandbox; scripts/build_launcher.sh
    # validates its generated launch agent with `plutil -lint`.
    cat > "$TMPDIR/bin/plutil" <<'EOF'
    #!${clangStdenv.shell}
    exec python3 ${./files/plutil.py} "$@"
    EOF
    chmod +x "$TMPDIR/bin/plutil"
    export PATH="$TMPDIR/bin:$PATH"
  '';

  buildPhase = ''
    runHook preBuild

    export HOME="$TMPDIR/home"
    mkdir -p "$HOME"

    # swift 6.4 propagates apple-sdk_27, whose SwiftUI declares @State as a
    # macro backed by an Xcode-only plugin (libSwiftUIMacros.dylib) that is not
    # shipped in the Nix store. Compile against apple-sdk_15 instead: it is what
    # the deployment target below was verified against, and its SwiftUI still
    # exposes the property wrappers.
    export SDKROOT="${apple-sdk_15}/Platforms/MacOSX.platform/Developer/SDKs/MacOSX.sdk"
    export NIX_APPLE_SDK_VERSION=150500

    export JAVA_HOME="${openjdk21}"
    export MACAPK_JDK_HOME="${openjdk21}"
    export CAPSTONE_ROOT="${capstone}"
    export LIBPNG_ROOT="${libpng.out}"
    export LIBPNG_INCLUDE_DIR="${libpng.dev}/include"
    export LIBVPX_ROOT="${libvpx.out}"
    export LIBVPX_INCLUDE_DIR="${libvpx.dev}/include"
    export AAPT2="${aapt}/bin/aapt2"
    export MACAPK_NO_SDK_FALLBACK=1
    export MACAPK_NO_BUNDLE_SYNC=1
    export MACAPK_BUILD_STAMP="261029.0000"
    export MACAPK_GIT_HASH="${builtins.substring 0 7 rev}"

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
