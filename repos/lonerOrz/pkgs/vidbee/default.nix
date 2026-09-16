{
  lib,
  stdenv,
  runCommand,
  fetchFromGitHub,
  nodejs_22,
  pnpm_11,
  pnpmConfigHook,
  fetchPnpmDeps,
  electron,
  makeWrapper,
  copyDesktopItems,
  makeDesktopItem,
  patchelf,
  python3,
  yt-dlp,
  ffmpeg,
  deno,
}:

let
  pname = "vidbee";
  version = "2.1.0";

  baseSrc = fetchFromGitHub {
    owner = "nexmoe";
    repo = "VidBee";
    tag = "v${version}";
    hash = "sha256-hXAVrryeYHWK2uqsLzD6QbaDPxvNwhdObY2PuQ+r1oY=";
  };

  # Replace the upstream manifest and lockfile with the Nix-maintained versions.
  src = runCommand "${pname}-src" { } ''
    mkdir -p "$out"
    cp -r ${baseSrc}/. "$out/"
    chmod -R u+w "$out"

    cp ${./package.json} "$out/package.json"
    cp ${./pnpm-lock.yaml} "$out/pnpm-lock.yaml"
  '';

  # Provide the GCC runtime libraries required by patched native addons.
  nativeRuntimePath = lib.makeLibraryPath [
    stdenv.cc.cc.lib
    stdenv.cc.cc.libgcc
  ];
in

stdenv.mkDerivation (finalAttrs: {
  inherit pname version src;

  strictDeps = true;

  pnpmDeps = fetchPnpmDeps {
    inherit (finalAttrs) pname version src;

    pnpm = pnpm_11;
    hash = "sha256-b5GZzbqR9fTEzoaMYyWIC5vt+C48zhP5JB+VDM8X4m0=";
    fetcherVersion = 4;
  };

  nativeBuildInputs = [
    copyDesktopItems
    makeWrapper
    patchelf
    nodejs_22
    pnpmConfigHook
    pnpm_11

    (python3.withPackages (ps: [
      ps.setuptools
    ]))
  ];

  buildInputs = [
    electron
  ];

  # Use nixpkgs' Electron instead of downloading an upstream binary.
  env.ELECTRON_SKIP_BINARY_DOWNLOAD = "1";

  postPatch = ''
    # Use the Nix resource path when the application runs from the store.
    substituteInPlace apps/desktop/src/main/lib/bundled-resources-path.ts \
      --replace-fail 'process.resourcesPath' \
      '(process.env.NIX_VIDBEE_RESOURCES || process.resourcesPath)'

    # Use the same Nix resource path for database migrations.
    substituteInPlace apps/desktop/src/main/lib/database/migrate.ts \
      --replace-fail 'process.resourcesPath' \
      '(process.env.NIX_VIDBEE_RESOURCES || process.resourcesPath)'
  '';

  desktopItems = [
    (makeDesktopItem {
      name = pname;
      desktopName = "VidBee";
      comment = "A modern Electron application for downloading videos and audios";
      exec = pname;
      categories = [ "Utility" ];
      mimeTypes = [ "x-scheme-handler/vidbee" ];
    })
  ];

  buildPhase = ''
    runHook preBuild

    # Install the complete workspace dependency graph from the prefetched store.
    pnpm install --offline --frozen-lockfile

    # Build VidBee.
    pnpm run build

    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall

    mkdir -p \
      "$out/bin" \
      "$out/lib/vidbee" \
      "$out/lib/vidbee/app" \
      "$out/lib/vidbee/resources"

    # Dereference pnpm symlinks so the runtime tree is self-contained.
    cp -aL apps/desktop/node_modules/. \
      "$out/lib/vidbee/app/node_modules/"

    # Install the generated application bundle.
    cp -r apps/desktop/out \
      "$out/lib/vidbee/app/"

    # Keep the desktop package metadata available at runtime.
    cp apps/desktop/package.json \
      "$out/lib/vidbee/app/package.json"

    # Install application-owned resources.
    cp -r apps/desktop/resources/. \
      "$out/lib/vidbee/resources/"

    # Use the nixpkgs runtime tools.
    ln -s ${yt-dlp}/bin/yt-dlp \
      "$out/lib/vidbee/resources/yt-dlp_linux"

    ln -s ${deno}/bin/deno \
      "$out/lib/vidbee/resources/deno"

    mkdir -p "$out/lib/vidbee/resources/node"
    ln -s ${nodejs_22}/bin/node \
      "$out/lib/vidbee/resources/node/node"

    mkdir -p "$out/lib/vidbee/resources/ffmpeg"
    ln -s ${ffmpeg}/bin/ffmpeg \
      "$out/lib/vidbee/resources/ffmpeg/ffmpeg"

    ln -s ${ffmpeg}/bin/ffprobe \
      "$out/lib/vidbee/resources/ffmpeg/ffprobe"

    # Remove native prebuilds for unsupported architectures and libc variants.
    find "$out/lib/vidbee/app/node_modules" \
      -type f \
      -name '*musl*.node' \
      -delete

    find "$out/lib/vidbee/app/node_modules" \
      -type f \
      -name '*linux-arm*.node' \
      -delete

    find "$out/lib/vidbee/app/node_modules" \
      -type f \
      -name '*linux-arm64*.node' \
      -delete

    find "$out/lib/vidbee/app/node_modules" \
      -type f \
      -name '*linux-ia32*.node' \
      -delete

    find "$out/lib/vidbee/app/node_modules" \
      -type f \
      -name '*darwin*.node' \
      -delete

    find "$out/lib/vidbee/app/node_modules" \
      -type f \
      -name '*win32*.node' \
      -delete

    # Launch VidBee with nixpkgs' Electron.
    makeWrapper ${electron}/bin/electron "$out/bin/vidbee" \
      --inherit-argv0 \
      --set ELECTRON_IS_DEV 0 \
      --set NIX_VIDBEE_RESOURCES "$out/lib/vidbee" \
      --add-flags "$out/lib/vidbee/app" \
      --add-flags "\''${NIXOS_OZONE_WL:+\''${WAYLAND_DISPLAY:+--ozone-platform-hint=auto --enable-features=WaylandWindowDecorations --enable-wayland-ime}}"

    install -Dm644 LICENSE \
      "$out/share/licenses/${finalAttrs.pname}/LICENSE"

    runHook postInstall
  '';

  postInstall = ''
    # Ensure the preload dependency survived the pnpm tree flattening.
    if test ! -d \
      "$out/lib/vidbee/app/node_modules/@electron-toolkit/preload"
    then
      echo "error: @electron-toolkit/preload is missing from the runtime dependency tree"
      ls -la "$out/lib/vidbee/app/node_modules/@electron-toolkit" \
        2>/dev/null || true
      exit 1
    fi

    # The preload dependency must be a real directory, not a build-tree symlink.
    if test -L \
      "$out/lib/vidbee/app/node_modules/@electron-toolkit/preload"
    then
      echo "error: @electron-toolkit/preload is still a symlink"
      readlink "$out/lib/vidbee/app/node_modules/@electron-toolkit/preload"
      exit 1
    fi

    # Patch better-sqlite3 to find the Nix GCC runtime.
    better_sqlite3_binding="$out/lib/vidbee/app/node_modules/better-sqlite3/prebuilds/linux-x64.node"

    if test ! -f "$better_sqlite3_binding"; then
      echo "error: better-sqlite3 linux-x64 native binding not found"
      find "$out/lib/vidbee/app/node_modules/better-sqlite3" \
        -maxdepth 4 \
        -print 2>/dev/null || true
      exit 1
    fi

    patchelf \
      --set-rpath "${nativeRuntimePath}" \
      "$better_sqlite3_binding"

    # Patch sherpa-onnx and its bundled shared libraries.
    sherpa_node="$(
      find "$out/lib/vidbee/app/node_modules" \
        -type f \
        -name 'sherpa-onnx.node' \
        -print -quit
    )"

    if test -z "$sherpa_node"; then
      echo "error: sherpa-onnx native addon was not found"
      exit 1
    fi

    sherpa_dir="$(dirname "$sherpa_node")"

    patchelf \
      --set-rpath "\$ORIGIN:${nativeRuntimePath}" \
      "$sherpa_node"

    for sherpa_library in \
      "$sherpa_dir/libsherpa-onnx-c-api.so" \
      "$sherpa_dir/libsherpa-onnx-cxx-api.so" \
      "$sherpa_dir/libonnxruntime.so"
    do
      if test -f "$sherpa_library"; then
        patchelf \
          --set-rpath "\$ORIGIN:${nativeRuntimePath}" \
          "$sherpa_library"
      fi
    done
  '';

  installCheckPhase = ''
    runHook preInstallCheck

    # Verify the runtime preload dependency.
    test -d \
      "$out/lib/vidbee/app/node_modules/@electron-toolkit/preload"

    test ! -L \
      "$out/lib/vidbee/app/node_modules/@electron-toolkit/preload"

    # Verify better-sqlite3 has no unresolved runtime libraries.
    better_sqlite3_binding="$out/lib/vidbee/app/node_modules/better-sqlite3/prebuilds/linux-x64.node"

    test -f "$better_sqlite3_binding"

    if ldd "$better_sqlite3_binding" 2>&1 | grep -q 'not found'; then
      echo "error: unresolved better-sqlite3 runtime dependency"
      ldd "$better_sqlite3_binding"
      exit 1
    fi

    # Verify sherpa-onnx has no unresolved runtime libraries.
    sherpa_node="$(
      find "$out/lib/vidbee/app/node_modules" \
        -type f \
        -name 'sherpa-onnx.node' \
        -print -quit
    )"

    if test -n "$sherpa_node"; then
      if ldd "$sherpa_node" 2>&1 | grep -q 'not found'; then
        echo "error: unresolved sherpa-onnx runtime dependency"
        ldd "$sherpa_node"
        exit 1
      fi
    fi

    # Verify runtime tools remain direct nixpkgs references.
    test -L "$out/lib/vidbee/resources/node/node"
    test -L "$out/lib/vidbee/resources/ffmpeg/ffmpeg"
    test -L "$out/lib/vidbee/resources/ffmpeg/ffprobe"
    test -L "$out/lib/vidbee/resources/deno"
    test -L "$out/lib/vidbee/resources/yt-dlp_linux"

    # Verify the selected Electron runtime and launcher.
    ${electron}/bin/electron --version
    test -x "$out/bin/vidbee"

    runHook postInstallCheck
  '';

  passthru.updateScript = ./update.sh;

  meta = {
    description = "A modern Electron application for downloading videos and audios";
    homepage = "https://vidbee.org/";
    changelog = "https://github.com/nexmoe/VidBee/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ lonerOrz ];
    platforms = lib.platforms.linux;
    mainProgram = pname;
    sourceProvenance = with lib.sourceTypes; [ fromSource ];
  };
})
