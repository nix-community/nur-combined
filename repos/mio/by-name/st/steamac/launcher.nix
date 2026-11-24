{
  lib,
  stdenv,
  version,
  steamacSrc,
  launcherSources,
  swiftpmDeps,
  libepoxy,
  virglrenderer,
  moltenvk,
  libkrun,
  gvproxy,
  desync,
  guestImages,
  gnused,
  python3,
}:

# Build the Swift launcher with upstream's own build.sh/bundle.sh. The scripts
# are patched only where they would use the network or rebuild the guest
# images: the vendored sources, SwiftPM cache, helper binaries and signed guest
# images are provided by the Nix derivations above.
stdenv.mkDerivation (finalAttrs: {
  pname = "steamac";
  inherit version;

  src = steamacSrc;

  dontConfigure = true;

  # Swift 6.2 (Xcode 26) times out type-checking two long concatenation
  # expressions in the launcher sources; the patch splits them up.
  patches = [ ./swift-6.2-typecheck.patch ];

  nativeBuildInputs = [ python3 ];

  # Xcode (swift, actool, vtool, codesign, Metal) and hdiutil live outside the
  # Nix store.
  __noChroot = true;

  postPatch = ''
    # build.sh downloads zstd/ENet/nanors and the gvproxy/desync binaries.
    substituteInPlace host/launcher/build.sh \
      --replace-fail '"$HERE/fetch-zstd.sh"' ":" \
      --replace-fail '"$HERE/fetch-enet.sh"' ":" \
      --replace-fail '"$HERE/fetch-nanors.sh"' ":" \
      --replace-fail '"$HERE/fetch-gvproxy.sh"' ":" \
      --replace-fail '"$HERE/fetch-desync.sh"' ":"

    # Dependencies are already resolved in .build (swiftpm-deps); never touch
    # the network or update the checkouts.
    substituteInPlace host/launcher/build.sh \
      --replace-fail 'SWIFT_FLAGS=(' \
        'SWIFT_FLAGS=(
    --disable-automatic-resolution
    --skip-update
    --disable-sandbox'

    # The guest images come from the signed upstream release (guest-images.nix)
    # rather than being rebuilt here, so the source-input receipts cannot match
    # this tree. The DMG hash in package.nix pins them instead.
    substituteInPlace host/launcher/bundle.sh \
      --replace-fail 'python3 "$ROOT/scripts/guest-artifacts.py" check-release' \
        '# guest images are pinned by the Nix package (package.nix)' \
      --replace-fail 'python3 "$ROOT/scripts/guest-artifacts.py" check-bundle "$TMP/Contents/Resources"' \
        '# guest images are pinned by the Nix package (package.nix)'

    # The complete third-party license inventory, including the guest-side GPL
    # notices, is part of the release (and of the pinned DMG).
    substituteInPlace host/launcher/bundle.sh \
      --replace-fail '"$HERE/licenses.sh"  # fail before modifying the existing app if a notice is unavailable' \
        '[[ -f "$OUT/licenses/THIRD-PARTY-NOTICES.txt" ]] || "$HERE/licenses.sh"'
  '';

  buildPhase = ''
    runHook preBuild

    host=work/out/host
    mkdir -p "$host/lib" "$host/include" "$host/bin" work/out

    # Store copies are read-only, and several of these derivations share
    # subdirectories (lib/pkgconfig), so make each merge writable as we go.
    cp -R ${libepoxy}/lib/. "$host/lib/"
    chmod -R u+w "$host"
    cp -R ${virglrenderer}/lib/. "$host/lib/"
    chmod -R u+w "$host"
    cp -R ${moltenvk}/lib/. "$host/lib/"
    cp -R ${moltenvk}/include/. "$host/include/"
    chmod -R u+w "$host"
    cp ${moltenvk}/MOLTENVK.txt "$host/"
    cp -R ${libkrun}/lib/. "$host/lib/"
    cp -R ${libkrun}/include/. "$host/include/"
    chmod -R u+w "$host"

    cp ${gvproxy}/bin/gvproxy "$host/bin/gvproxy"
    cp ${desync}/bin/desync "$host/bin/desync"

    cp -R ${guestImages}/Image ${guestImages}/initramfs.cpio.gz ${guestImages}/steamac-layer.img \
      ${guestImages}/*.inputs.json work/out/
    cp -R ${guestImages}/licenses work/out/licenses

    cp -R ${launcherSources}/CZstd/. host/launcher/Sources/CZstd/
    cp -R ${launcherSources}/CEnet/. host/launcher/Sources/CEnet/
    cp -R ${launcherSources}/CNanors/. host/launcher/Sources/CNanors/

    # Store copies are read-only; the bundle and signing steps write into them.
    chmod -R u+w work/out host

    mkdir -p host/launcher/.build
    cp -R ${swiftpmDeps}/. host/launcher/.build/
    chmod -R u+w host/launcher/.build
    # SwiftPM's workspace state stores absolute paths; restore them for this
    # build tree (swiftpm-deps normalised them to a placeholder).
    grep -rl --binary-files=without-match -- '@STEAMAC_LAUNCHER@' host/launcher/.build \
      | xargs -r ${gnused}/bin/sed -i "s|@STEAMAC_LAUNCHER@|$PWD/host/launcher|g"

    # SwiftPM/Xcode write caches under HOME; the Nix default is not writable.
    export HOME="$PWD/.home"
    mkdir -p "$HOME"
    # SwiftPM's /usr/bin/swift shim does not resolve its sibling frontend
    # inside the build sandbox; put the real Xcode driver first on PATH.
    export PATH="/usr/bin:/bin:/usr/sbin:/sbin:$PATH"
    # stdenv points DEVELOPER_DIR at the Nix apple-sdk, which has no Swift
    # toolchain; xcrun must look at the real Xcode.
    unset DEVELOPER_DIR SDKROOT
    toolchain_bin=$(dirname "$(xcrun --find swift)")
    export PATH="$toolchain_bin:$PATH"
    export SWIFT_EXEC="$(xcrun --find swiftc)"
    export KRUN_PREFIX="$PWD/$host"
    bash host/launcher/build.sh

    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall
    mkdir -p "$out/Applications" "$out/bin"
    cp -R "work/out/FX Steam Launcher.app" "$out/Applications/"
    ln -s "$out/Applications/FX Steam Launcher.app/Contents/MacOS/steamac-vm" "$out/bin/steamac-vm"
    runHook postInstall
  '';

  dontFixup = true;

  passthru.moltenvk = moltenvk;

  meta = {
    description = "Run Valve's ARM64 SteamOS in a lightweight VM on Apple Silicon";
    mainProgram = "steamac-vm";
    homepage = "https://fxgl.github.io/steamac/";
    license = lib.licenses.asl20;
    platforms = [ "aarch64-darwin" ];
  };
})
