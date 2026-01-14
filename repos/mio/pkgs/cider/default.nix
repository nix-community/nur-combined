{
  lib,
  stdenv,
  fetchFromGitHub,
  nodejs_22,
  fetchPnpmDeps,
  pnpmConfigHook,
  pnpm,
  makeWrapper,
  node-gyp,
  pkg-config,
  python3,
  writableTmpDirAsHomeHook,
  electron,
  copyDesktopItems,
  makeDesktopItem,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "cider";
  version = "1.6.3-unstable-20251216";

  src = fetchFromGitHub {
    owner = "taoky";
    repo = "Cider";
    rev = "8ee858eea47871de0e7de03fa31c477740a56f85";
    hash = "sha256-ziTjLNyBbGBg7++AspjqJTs56JMvgGkaDBP0Ou3Sk24=";
  };

  pnpmDeps = fetchPnpmDeps {
    inherit (finalAttrs) pname version src;
    fetcherVersion = 2;
    hash = "sha256-ztHv5b91xe5EavKMJ88Bhfi3AkjmieezNuDIz+kM+9w=";
  };

  nativeBuildInputs = [
    nodejs_22
    pnpmConfigHook
    pnpm
    makeWrapper
    node-gyp
    pkg-config
    python3
    writableTmpDirAsHomeHook
    copyDesktopItems
  ];

  env = {
    npm_config_build_from_source = "true";
    NPM_CONFIG_MANAGE_PACKAGE_MANAGER_VERSIONS = "false";
    ELECTRON_SKIP_BINARY_DOWNLOAD = "1";
  };

  postPatch = ''
    # Avoid pnpm trying to self-manage the version (network access) in the build.
    sed -i '/"packageManager":/d' package.json
  '';

  buildPhase = ''
    runHook preBuild

    # prevent node-gyp from downloading Electron headers
    export ELECTRON_HEADERS_DIR="$PWD/.electron-headers"
    mkdir -p "$ELECTRON_HEADERS_DIR"
    cp -R ${electron.headers}/node_headers/* "$ELECTRON_HEADERS_DIR"
    ln -s "$ELECTRON_HEADERS_DIR/include/node/common.gypi" "$ELECTRON_HEADERS_DIR/common.gypi"
    ln -s "$ELECTRON_HEADERS_DIR/include/node/config.gypi" "$ELECTRON_HEADERS_DIR/config.gypi"
    export npm_config_nodedir="$ELECTRON_HEADERS_DIR"

    pnpm config set nodedir ${nodejs_22}
    pnpm install --offline --frozen-lockfile
    pnpm run build

    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall

    mkdir -p $out/lib/cider $out/bin
    cp -R build resources node_modules package.json src $out/lib/cider/

    install -Dm644 resources/icons/icon.png \
      $out/share/icons/hicolor/256x256/apps/sh.cider.Cider.png

    makeWrapper ${lib.getExe electron} $out/bin/sh.cider.Cider \
      --add-flags $out/lib/cider/build/index.js \
      --set NODE_PATH "$out/lib/cider/node_modules" \
      --set ELECTRON_FORCE_IS_PACKAGED 1 \
      --add-flags "\''${NIXOS_OZONE_WL:+\''${WAYLAND_DISPLAY:+--ozone-platform-hint=auto --enable-features=WaylandWindowDecorations --enable-wayland-ime=true --wayland-text-input-version=3}}" \
      --set-default ELECTRON_IS_DEV 0 \
      --inherit-argv0
    ln -s $out/bin/sh.cider.Cider $out/bin/cider

    runHook postInstall
  '';

  desktopItems = [
    (makeDesktopItem {
      name = "sh.cider.Cider";
      desktopName = "Cider";
      exec = "sh.cider.Cider";
      icon = "sh.cider.Cider";
      categories = [
        "Audio"
        "AudioVideo"
        "Player"
      ];
    })
  ];

  meta = {
    description = "Apple Music client based on Electron and Vue.js";
    homepage = "https://github.com/taoky/Cider";
    license = lib.licenses.agpl3Only;
    platforms = lib.platforms.linux;
    mainProgram = "sh.cider.Cider";
  };
})
