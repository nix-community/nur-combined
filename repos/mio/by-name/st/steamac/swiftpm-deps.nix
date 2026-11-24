{
  lib,
  stdenv,
  steamacSrc,
  git,
  cacert,
  xz,
  gnused,
}:

# `swift build` would resolve Sentry and Sparkle from the network. Resolve them
# once in a fixed-output derivation; the launcher build then copies this .build
# directory in and builds with --disable-automatic-resolution.
stdenv.mkDerivation {
  name = "steamac-swiftpm-deps";

  src = steamacSrc;

  nativeBuildInputs = [
    git
    cacert
    xz
  ];

  dontConfigure = true;
  # Keep the checkouts byte-identical: the fixup phase's shebang rewriting
  # would both make the output non-reproducible and add store references that
  # a fixed-output derivation may not have.
  dontFixup = true;

  # SwiftPM and Xcode live outside the Nix store.
  __noChroot = true;

  buildPhase = ''
    runHook preBuild

    # SwiftPM's /usr/bin/swift shim does not resolve its sibling frontend
    # inside the build sandbox; put the real Xcode driver first on PATH.
    # Do not export PATH here: the fixup phase would then pick up BSD stat
    # from /usr/bin. Only the SwiftPM invocation needs the Xcode tools.
    export PATH="/usr/bin:/bin:/usr/sbin:/sbin:$PATH"
    # stdenv points DEVELOPER_DIR at the Nix apple-sdk, which has no Swift
    # toolchain; xcrun must look at the real Xcode.
    unset DEVELOPER_DIR SDKROOT
    toolchain_bin=$(dirname "$(xcrun --find swift)")
    export SWIFT_EXEC="$(xcrun --find swiftc)"
    export HOME="$PWD/.home"
    mkdir -p "$HOME"
    export GIT_SSL_CAINFO=${cacert}/etc/ssl/certs/ca-bundle.crt

    cd host/launcher
    # SwiftPM's manifest sandbox cannot find the Xcode tools here; the Nix
    # build is already sandboxed.
    PATH="$toolchain_bin:$PATH" swift package resolve --disable-sandbox

    # Git metadata and bare repositories would make the fixed-output hash
    # depend on clone details; SwiftPM's workspace-state.json is enough.
    rm -rf .build/repositories
    find .build/checkouts -name .git -type d -prune -exec rm -rf {} +

    # Resolution downloads every binary artifact of sentry-cocoa; the launcher
    # only needs the Sentry.xcframework that SwiftPM insists on for the binary
    # target, so drop its siblings (and their extracted copies) to keep the
    # fixed-output store path small.
    if [ -d .build/artifacts/sentry-cocoa ]; then
      find .build/artifacts/sentry-cocoa -mindepth 1 -maxdepth 1 ! -name Sentry -exec rm -rf {} +
    fi

    # workspace-state.json stores absolute checkout/artifact paths. Normalise
    # the build directory so the fixed-output hash does not depend on it; the
    # launcher build substitutes its own path back in.
    root=$PWD
    grep -rl --binary-files=without-match -- "$root" .build \
      | xargs -r ${gnused}/bin/sed -i "s|$root|@STEAMAC_LAUNCHER@|g"

    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall
    mkdir -p "$out"
    cp -R "$NIX_BUILD_TOP/source/host/launcher/.build/." "$out"/
    runHook postInstall
  '';

  outputHashMode = "recursive";
  outputHash = "sha256-+dmzNhayPDfYynbb1fGiT0K5o9TSDyOdDI3jXGBBzzY=";

  meta = {
    description = "SwiftPM dependency cache for the Steamac launcher";
    platforms = [ "aarch64-darwin" ];
  };
}
