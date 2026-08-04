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
  libxcb,
  libx11,
  cairo,
  libGL,
  node-gyp,
}:
let
  # Only instantiate the custom backend on Linux; Darwin uses the bundled binary from the app
  customBackend = if stdenv.hostPlatform.isLinux then pkgs.callPackage ./backend.nix { } else null;
in
stdenv.mkDerivation (finalAttrs: {
  pname = "beam-studio";
  version = "2.6.8-stable";

  src = fetchFromGitHub {
    owner = "flux3dp";
    repo = "beam-studio";
    tag = "app-2.6.8-stable";
    hash = "sha256-sKJhNvulqLYDko7uwzlGNexx81XUFNM1aJjZHOnCrc0=";
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
    node-gyp
    pnpmConfigHook
    pnpm_10
    pkg-config
  ]
  ++ lib.optionals stdenv.hostPlatform.isLinux [
    copyDesktopItems
    autoPatchelfHook
  ];

  buildInputs = [
    fontconfig
    freetype
    cairo
  ]
  ++ lib.optionals stdenv.hostPlatform.isLinux [
    stdenv.cc.cc.lib
    libxcb
    libx11
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

    export XDG_CACHE_HOME=$(mktemp -d)
    export FONTCONFIG_FILE=${fontconfig.out}/etc/fonts/fonts.conf
    export FONTCONFIG_PATH=${fontconfig.out}/etc/fonts

    # prevent node-gyp from downloading Electron headers
    export ELECTRON_HEADERS_DIR="$PWD/.electron-headers"
    mkdir -p "$ELECTRON_HEADERS_DIR"
    cp -R ${electron.headers}/* "$ELECTRON_HEADERS_DIR/"
    ln -s "$ELECTRON_HEADERS_DIR/include/node/common.gypi" "$ELECTRON_HEADERS_DIR/common.gypi"
    ln -s "$ELECTRON_HEADERS_DIR/include/node/config.gypi" "$ELECTRON_HEADERS_DIR/config.gypi"
    export npm_config_nodedir="$ELECTRON_HEADERS_DIR"

    pnpm rebuild

    # Patch prebuilt binaries in node_modules
    ${lib.optionalString stdenv.hostPlatform.isLinux "autoPatchelf node_modules"}

    # Match the official build size by building the Node bundle in production mode
    substituteInPlace apps/app/webpack.node.js \
      --replace-fail "mode: 'development'" "mode: 'production'"

    # Beam Studio build
    pnpm --filter @beam-studio/app run build
    pnpm --filter @beam-studio/app run build-node

    # In a Nix environment wrapper, process.defaultApp is true.
    # This causes Electron to incorrectly use '.' instead of process.resourcesPath
    # and opens DevTools on startup. Replace it with false.
    substituteInPlace apps/app/public/js/node/main.js \
      --replace-fail 'process.defaultApp' 'false'

    # process.resourcesPath points to the electron binary's resources directory,
    # not the app's resources directory. Fix it to point to our app.asar's parent.
    substituteInPlace apps/app/public/js/node/main.js \
      --replace-fail 'process.resourcesPath' 'require("path").join(__dirname, "../../../../")'

    # Build font-scanner AFTER webpack to prevent fontconfig hangs during webpack.
    # Also patch NULL-init bug: missing fontconfig attributes otherwise segfault
    # in copyString and freeze the UI via sync GetAvailableFonts IPC.
    for dir in $(find node_modules -path "*/node_modules/font-scanner" -type d); do
      if [ -f "$dir/binding.gyp" ]; then
        echo "Patching and building $dir"
        patch -d "$dir" -p1 < ${./font-scanner-null-init.patch}
        (cd "$dir" && node-gyp rebuild)
        ${lib.optionalString stdenv.hostPlatform.isLinux ''autoPatchelf "$dir"''}
      fi
    done

    # Run electron-builder
    cp -r ${electron.dist} electron-dist
    chmod -R u+w electron-dist

    cd apps/app
    ${
      if stdenv.hostPlatform.isDarwin then
        ''
          # Disable codesigning and icon compilation (actool/codesign not in Nix sandbox)
          CSC_IDENTITY_AUTO_DISCOVERY=false pnpm exec electron-builder \
            --dir \
            -c.electronDist=../../electron-dist \
            -c.electronVersion=${electron.version} \
            -c.npmRebuild=false \
            -c.asarUnpack="**/*.node" \
            -c.mac.target=dir \
            -c.mac.icon=null \
            -c.mac.identity=null
        ''
      else
        ''
          pnpm exec electron-builder \
            --dir \
            -c.electronDist=../../electron-dist \
            -c.electronVersion=${electron.version} \
            -c.npmRebuild=false \
            -c.asarUnpack="**/*.node" \
            -c.linux.target=dir
        ''
    }
    cd ../..

    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall

    ${
      if stdenv.hostPlatform.isDarwin then
        ''
          mkdir -p $out/Applications
          # electron-builder --dir outputs to dist/mac-arm64/ (no -unpacked suffix) on darwin
          appDir=$(echo apps/app/dist/mac*/"Beam Studio.app" 2>/dev/null | head -1)
          if [ -z "$appDir" ] || [ ! -d "$appDir" ]; then
            echo "ERROR: Could not find 'Beam Studio.app' in apps/app/dist/"
            find apps/app/dist/ -maxdepth 2 -type d || true
            exit 1
          fi
          cp -r "$appDir" $out/Applications/

          mkdir -p $out/bin
          makeWrapper "$out/Applications/Beam Studio.app/Contents/MacOS/Beam Studio" $out/bin/beam-studio \
            --set ELECTRON_FORCE_IS_PACKAGED 1 \
            --set ELECTRON_IS_DEV 0
        ''
      else
        ''
          mkdir -p $out/share/beam-studio
          cp -r apps/app/dist/linux-unpacked/locales $out/share/beam-studio/
          cp -r apps/app/dist/linux-unpacked/resources $out/share/beam-studio/

          # Setup our source-built custom backend (Linux AppImage does not use swiftray)
          mkdir -p $out/share/beam-studio/resources/backend/flux_api
          ln -s ${customBackend}/bin/flux_api $out/share/beam-studio/resources/backend/flux_api/flux_api

          mkdir -p $out/bin
          # Required: Chromium's sandbox needs user namespaces; NixOS often disables them,
          # and the official AppImage also hardcodes --no-sandbox for the same reason.
          makeWrapper ${electron}/bin/electron $out/bin/beam-studio \
            --add-flags $out/share/beam-studio/resources/app.asar \
            --add-flags "''${NIXOS_OZONE_WL:+''${WAYLAND_DISPLAY:+--ozone-platform-hint=auto --enable-features=WaylandWindowDecorations --enable-wayland-ime=true --wayland-text-input-version=3}}" \
            --add-flags "--no-sandbox" \
            --set-default FONTCONFIG_FILE /etc/fonts/fonts.conf \
            --set-default FONTCONFIG_PATH /etc/fonts \
            --set-default ELECTRON_FORCE_IS_PACKAGED 1 \
            --set-default ELECTRON_IS_DEV 0 \
            --inherit-argv0

          # Install the application icon
          mkdir -p $out/share/icons/hicolor/512x512/apps
          cp apps/app/public/img/icon.png $out/share/icons/hicolor/512x512/apps/beam-studio.png
        ''
    }

    runHook postInstall
  '';

  desktopItems = lib.optionals stdenv.hostPlatform.isLinux [
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
    description = "Laser cutting and engraving software for FLUX machines";
    homepage = "https://github.com/flux3dp/beam-studio";
    license = with lib.licenses; [
      agpl3Only
      unfree
    ];
    maintainers = [ ];
    mainProgram = "beam-studio";
    platforms = lib.platforms.linux ++ lib.platforms.darwin;
  };
})
