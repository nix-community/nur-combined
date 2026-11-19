{
  lib,
  writeShellApplication,
  stdenv,
  fetchFromGitHub,
  fetchPnpmDeps,
  fetchNpmDeps,
  pnpmConfigHook,
  pnpm_10,
  nodejs_22,
  jq,
  electron,
  makeWrapper,
  copyDesktopItems,
  makeDesktopItem,
  autoPatchelfHook,
  writableTmpDirAsHomeHook,
  nix-update-script,
}:

let
  pnpm = pnpm_10;
  isDarwin = stdenv.hostPlatform.isDarwin;
  isLinux = stdenv.hostPlatform.isLinux;
in
stdenv.mkDerivation (finalAttrs: {
  pname = "chatbox";
  version = "1.24.4";

  src = fetchFromGitHub {
    owner = "chatboxai";
    repo = "chatbox";
    tag = "v${finalAttrs.version}";
    hash = "sha256-svygHJVZSNwocl9jTiivBwzW4zUXot8x+9rSk5SOZGE=";
  };

  pnpmDeps = fetchPnpmDeps {
    inherit (finalAttrs) pname version src;
    inherit pnpm;
    fetcherVersion = 4;
    prePnpmInstall = ''
      sed -i 's/engine-strict=true/engine-strict=false/' .npmrc
    '';
    hash = "sha256-KxxfHApHefvJp8dFs17dSJraD5PCRDP0Ms+2BJTffJI=";
  };

  # Nested electron-react-boilerplate app; electron-builder only packages this
  # tree, so it needs its own offline npm dependency set.
  appNpmDeps = fetchNpmDeps {
    name = "chatbox-app-npm-deps-${finalAttrs.version}";
    src = "${finalAttrs.src}/release/app";
    hash = "sha256-1+gVNAfkA8h1qTVWGGxYKOHvQOEkBmWKMrtQUNqfimI=";
  };

  nativeBuildInputs = [
    nodejs_22
    jq
    pnpm
    pnpmConfigHook
    writableTmpDirAsHomeHook
    # Script wrapper so NIXOS_OZONE_WL expands at runtime.
    # https://github.com/NixOS/nixpkgs/issues/172583
    makeWrapper
  ]
  ++ lib.optionals isLinux [
    copyDesktopItems
    autoPatchelfHook
  ];

  buildInputs = lib.optionals isLinux [ stdenv.cc.cc.lib ];

  # @libsql and @vscode/ripgrep-universal ship musl prebuilds that are never
  # loaded on NixOS.
  autoPatchelfIgnoreMissingDeps = lib.optionals isLinux [ "libc.musl-*.so.*" ];

  strictDeps = true;

  env = {
    ELECTRON_SKIP_BINARY_DOWNLOAD = "1";
    CSC_IDENTITY_AUTO_DISCOVERY = "false";
    HUSKY = "0";
    NPM_CONFIG_MANAGE_PACKAGE_MANAGER_VERSIONS = "false";
    npm_config_engine_strict = "false";
    CHATBOX_BUILD_PLATFORM = if isDarwin then "darwin" else "linux";
    CHATBOX_BUILD_TARGET = "desktop";
    # electron-builder.yml interpolates this even when publishing is disabled.
    UPDATE_CHANNEL = "nix";
  };

  postPatch = ''
    substituteInPlace .npmrc \
      --replace-fail 'engine-strict=true' 'engine-strict=false'

    # Rewrite a JSON file in place, keeping jq options and filter in order.
    jqEdit() {
      local file=$1
      shift
      jq "$@" "$file" > "$file.tmp"
      mv "$file.tmp" "$file"
    }

    # corepack must not try to download the pinned package manager.
    jqEdit package.json '._packageManager = .packageManager | del(.packageManager)'

    # Align the nested app lockfile with package.json so npm ci can run offline.
    jqEdit release/app/package-lock.json --slurpfile pkg release/app/package.json '
      .name = $pkg[0].name
      | .version = $pkg[0].version
      | .packages[""].name = $pkg[0].name
      | .packages[""].version = $pkg[0].version
    '

    # Wrapping nixpkgs electron leaves process.resourcesPath pointing at Electron's
    # own resources. Pin extraResources (icons, ripgrep) to this package.
    # https://github.com/electron/electron/issues/31121
    substituteInPlace src/main/main.ts src/main/ripgrep-search.ts \
      --replace-fail 'process.resourcesPath' "'$out/share/chatbox/resources'"

    # Wrapping as "electron app.asar" sets process.defaultApp and would register chatbox-dev://.
    substituteInPlace src/main/main.ts \
      --replace-fail 'process.defaultApp' 'false'

    # Nix installs updates; do not fetch upstream AppImage/deb payloads.
    substituteInPlace src/main/app-updater.ts \
      --replace-fail 'if (settings.autoUpdate) {' 'if (false) {'

    # beforePack would run npm ci on the network, and notarization is already
    # disabled through CSC_IDENTITY_AUTO_DISCOVERY.
    install -Dm644 ${./ensure-app-deps.cjs} .erb/scripts/ensure-app-deps.cjs
    install -Dm644 ${./notarize.js} .erb/scripts/notarize.js
  '';

  buildPhase = ''
    runHook preBuild

    pnpm run build

    cache="$TMPDIR/app-npm-cache"
    cp -r ${finalAttrs.appNpmDeps} "$cache"
    chmod -R u+w "$cache"
    rm -rf release/app/node_modules
    (
      cd release/app
      npm ci --offline --omit=dev --ignore-scripts --cache "$cache"
    )

    cp -r ${electron.dist} electron-dist
    chmod -R u+w electron-dist

    ./node_modules/.bin/electron-builder \
      --dir \
      --config electron-builder.yml \
      -c.electronDist="$PWD/electron-dist" \
      -c.electronVersion=${electron.version} \
      -c.npmRebuild=false \
      -p never \
      -c.mac.identity=null

    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall
  ''
  + lib.optionalString isDarwin ''
    appDir=
    for d in release/build/mac*/Chatbox.app; do
      if [ -d "$d" ]; then
        appDir="$d"
        break
      fi
    done
    if [ -z "$appDir" ]; then
      echo "error: Chatbox.app not found"
      find release/build -maxdepth 4 -type d || true
      exit 1
    fi

    mkdir -p $out/Applications $out/bin
    cp -Pr --no-preserve=ownership "$appDir" $out/Applications/
    makeWrapper "$out/Applications/Chatbox.app/Contents/MacOS/Chatbox" $out/bin/chatbox
  ''
  + lib.optionalString isLinux ''
    mkdir -p $out/share/chatbox
    cp -Pr --no-preserve=ownership release/build/*-unpacked/{locales,resources{,.pak}} $out/share/chatbox

    install -Dm644 assets/icon.png $out/share/icons/hicolor/512x512/apps/chatbox.png

    # The flags come from the environment at runtime, hence the nested expansion.
    makeWrapper ${lib.getExe electron} $out/bin/chatbox \
      --add-flags $out/share/chatbox/resources/app.asar \
      --add-flags "\''${NIXOS_OZONE_WL:+\''${WAYLAND_DISPLAY:+--ozone-platform-hint=auto --enable-features=WaylandWindowDecorations --enable-wayland-ime=true --wayland-text-input-version=3}}" \
      --set-default ELECTRON_FORCE_IS_PACKAGED 1 \
      --set-default ELECTRON_IS_DEV 0 \
      --inherit-argv0
  ''
  + ''
    runHook postInstall
  '';

  desktopItems = lib.optionals isLinux [
    (makeDesktopItem {
      name = "chatbox";
      exec = "chatbox %U";
      icon = "chatbox";
      desktopName = "Chatbox";
      genericName = "AI Client";
      comment = finalAttrs.meta.description;
      categories = [
        "Network"
        "Office"
        "Chat"
      ];
      startupWMClass = "Chatbox";
      mimeTypes = [ "x-scheme-handler/chatbox" ];
    })
  ];

  passthru = {
    # Exposed so `nix-update --subpackage=appNpmDeps` can refresh its hash.
    inherit (finalAttrs) pnpmDeps appNpmDeps;
    updateScript = writeShellApplication {
      name = "update-chatbox";
      text = ''
        export UPDATE_NIX_ATTR_PATH="chatbox"
        exec ${
          lib.escapeShellArgs (nix-update-script {
            extraArgs = [ "--subpackage=appNpmDeps" ];
          })
        } "$@"
      '';
    };
  };

  meta = {
    description = "Desktop client for ChatGPT, Claude, and other LLMs";
    homepage = "https://github.com/chatboxai/chatbox";
    changelog = "https://github.com/chatboxai/chatbox/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.gpl3Only;
    mainProgram = "chatbox";
    platforms = [
      "x86_64-linux"
      "aarch64-linux"
    ]
    ++ lib.platforms.darwin;
    sourceProvenance = with lib.sourceTypes; [
      fromSource
      binaryNativeCode # @libsql prebuilds, @vscode/ripgrep-universal
    ];
  };
})
