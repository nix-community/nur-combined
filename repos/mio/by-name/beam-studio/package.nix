{
  pkgs,
  lib,
  stdenv,
  fetchFromGitHub,
  makeWrapper,
  electron,
  python3,
  nodejs,
  pnpm_10,
  fetchPnpmDeps,
  pnpmConfigHook,
  makeDesktopItem,
  copyDesktopItems,
  autoPatchelfHook,
  pkg-config,
  fontconfig,
  freetype,
  fetchurl,
  appimageTools,
  libxcb,
  libx11,
  cairo,
  libGL,
}:
let
  customBackend = pkgs.callPackage ./backend.nix { };
in
stdenv.mkDerivation (finalAttrs: {
  pname = "beam-studio";
  version = "2.6.8-stable";

  src = fetchFromGitHub {
    owner = "flux3dp";
    repo = "beam-studio";
    rev = "refs/tags/app-2.6.8-stable";
    hash = "sha256-gfmIuw3aKDzAFGIDZTs1V/mDIkDWDvdbb+dJ9m0OOeQ=";
  };

  pnpmDeps = fetchPnpmDeps {
    inherit (finalAttrs) pname version src;
    pnpm = pnpm_10;
    fetcherVersion = 4;
    hash = "sha256-4LZ37gYPpFQ/tR/T8R+bdvnp5tHllcdSPwjml9B1uHo=";
  };

  nativeBuildInputs = [
    makeWrapper
    python3
    nodejs
    pnpmConfigHook
    pnpm_10
    copyDesktopItems
    autoPatchelfHook
    pkg-config
  ];

  buildInputs = [
    stdenv.cc.cc.lib
    fontconfig
    freetype
    libxcb
    libx11
    cairo
    libGL
  ];

  env = {
    ELECTRON_SKIP_BINARY_DOWNLOAD = "1";
    PUBLISH_PATH = "";
    PUBLISH_SUFFIX = "";
    npm_config_build_from_source = "true";
  };

  buildPhase = ''
    runHook preBuild

    # prevent node-gyp from downloading Electron headers
    export ELECTRON_HEADERS_DIR="$PWD/.electron-headers"
    mkdir -p "$ELECTRON_HEADERS_DIR"
    cp -R ${electron.headers}/* "$ELECTRON_HEADERS_DIR/"
    ln -s "$ELECTRON_HEADERS_DIR/include/node/common.gypi" "$ELECTRON_HEADERS_DIR/common.gypi"
    ln -s "$ELECTRON_HEADERS_DIR/include/node/config.gypi" "$ELECTRON_HEADERS_DIR/config.gypi"
    export npm_config_nodedir="$ELECTRON_HEADERS_DIR"

    pnpm rebuild

    # Patch prebuilt binaries in node_modules
    autoPatchelf node_modules

    # Beam Studio build
    pnpm --filter @beam-studio/app run build
    pnpm --filter @beam-studio/app run build-node

    # Run electron-builder
    cp -r ${electron.dist} electron-dist
    chmod -R u+w electron-dist

    cd apps/app
    pnpm exec electron-builder \
      --dir \
      -c.electronDist=../../electron-dist \
      -c.electronVersion=${electron.version} \
      -c.npmRebuild=false \
      -c.asarUnpack="**/*.node" \
      -c.linux.target=dir
    cd ../..

    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall

    mkdir -p $out/share/beam-studio
    cp -r apps/app/dist/linux-unpacked/locales $out/share/beam-studio/
    cp -r apps/app/dist/linux-unpacked/resources $out/share/beam-studio/
    cp apps/app/dist/linux-unpacked/*.pak $out/share/beam-studio/ || true

    # Setup our source-built custom backend (Linux AppImage does not use swiftray)
    mkdir -p $out/share/beam-studio/resources/backend/flux_api
    ln -s ${customBackend}/bin/flux_api $out/share/beam-studio/resources/backend/flux_api/flux_api

    mkdir -p $out/bin
    makeWrapper ${electron}/bin/electron $out/bin/beam-studio \
      --add-flags $out/share/beam-studio/resources/app.asar \
      --add-flags "\''${NIXOS_OZONE_WL:+\''${WAYLAND_DISPLAY:+--ozone-platform-hint=auto --enable-features=WaylandWindowDecorations --enable-wayland-ime=true --wayland-text-input-version=3}}" \
      --add-flags "--disable-dev-shm-usage" \
      --set-default ELECTRON_FORCE_IS_PACKAGED 1 \
      --set-default ELECTRON_IS_DEV 0 \
      --inherit-argv0

    runHook postInstall
  '';

  desktopItems = [
    (makeDesktopItem {
      name = "beam-studio";
      exec = "beam-studio %U";
      icon = "beam-studio";
      desktopName = "Beam Studio";
      comment = finalAttrs.meta.description;
      categories = [
        "Graphics"
        "Engineering"
      ];
      startupWMClass = "Beam Studio";
    })
  ];

  meta = {
    description = "Beam Studio";
    homepage = "https://github.com/flux3dp/beam-studio";
    # Note: While the backend components are proprietary (unfree), beam-studio is
    # licensed under AGPL-3.0. According to the Software Freedom Conservancy,
    # users might or might not be entitled to reverse engineer the combined work to exercise their
    # rights under the AGPL-3.0. Please consult a lawyer if you are unsure about your rights.
    license = with lib.licenses; [
      agpl3Only
      unfree
    ];
    maintainers = [ ];
    mainProgram = "beam-studio";
    platforms = lib.platforms.linux;
  };
})
