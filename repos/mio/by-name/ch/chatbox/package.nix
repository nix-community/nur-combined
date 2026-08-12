{
  lib,
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
in
stdenv.mkDerivation (finalAttrs: {
  pname = "chatbox";
  version = "1.22.3";

  src = fetchFromGitHub {
    owner = "chatboxai";
    repo = "chatbox";
    tag = "v${finalAttrs.version}";
    hash = "sha256-Ar2gvnhPdwW9myhSQ/5ND3t5DoMxaca4t7lexBNdDZc=";
  };

  pnpmDeps = fetchPnpmDeps {
    inherit (finalAttrs) pname version src;
    inherit pnpm;
    fetcherVersion = 4;
    prePnpmInstall = ''
      sed -i 's/engine-strict=true/engine-strict=false/' .npmrc
    '';
    hash = "sha256-qZ62qAUmd2HlSGQvbP6YBFzWUyqGrZKnvmURT0knHX8=";
  };

  # Nested electron-react-boilerplate app; electron-builder only packages this tree.
  appNpmDeps = fetchNpmDeps {
    name = "chatbox-app-npm-deps-${finalAttrs.version}";
    src = "${finalAttrs.src}/release/app";
    hash = "sha256-TsHwflraAWtLYb/dH8+nDv+AAfh9/zND6a8nzfbI0qg=";
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
  ++ lib.optionals stdenv.hostPlatform.isLinux [
    copyDesktopItems
    autoPatchelfHook
  ];

  buildInputs = lib.optionals stdenv.hostPlatform.isLinux [ stdenv.cc.cc.lib ];

  autoPatchelfIgnoreMissingDeps = [ "libc.musl-*.so.*" ];

  strictDeps = true;

  env = {
    ELECTRON_SKIP_BINARY_DOWNLOAD = "1";
    CSC_IDENTITY_AUTO_DISCOVERY = "false";
    HUSKY = "0";
    NPM_CONFIG_MANAGE_PACKAGE_MANAGER_VERSIONS = "false";
    npm_config_engine_strict = "false";
    CHATBOX_BUILD_PLATFORM = if stdenv.hostPlatform.isDarwin then "darwin" else "linux";
    CHATBOX_BUILD_TARGET = "desktop";
    # electron-builder.yml interpolates this even when publishing is disabled.
    UPDATE_CHANNEL = "nix";
  };

  postPatch = ''
    substituteInPlace .npmrc \
      --replace-fail 'engine-strict=true' 'engine-strict=false'

    jq '._packageManager = .packageManager | del(.packageManager)' package.json > package.json.tmp
    mv package.json.tmp package.json

    # Align the nested app lockfile with package.json so npm ci can run offline.
    jq --slurpfile pkg release/app/package.json '
      .name = $pkg[0].name
      | .version = $pkg[0].version
      | .packages[""].name = $pkg[0].name
      | .packages[""].version = $pkg[0].version
    ' release/app/package-lock.json > release/app/package-lock.json.tmp
    mv release/app/package-lock.json.tmp release/app/package-lock.json

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

    # beforePack would run npm ci on the network; we install those deps offline.
    cat > .erb/scripts/ensure-app-deps.cjs <<'EOF'
    const path = require("path");
    const { verifyInstalledRuntimeDeps } = require("./runtime-deps.cjs");

    exports.default = async function ensureAppDeps() {
      verifyInstalledRuntimeDeps(path.join(__dirname, "..", "..", "release", "app"));
    };
    EOF

    # Skip Apple notarization; identity is already disabled.
    cat > .erb/scripts/notarize.js <<'EOF'
    exports.default = async function notarize() {};
    EOF
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
  + lib.optionalString stdenv.hostPlatform.isDarwin ''
    mkdir -p $out/share/chatbox
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
    cp -Pr --no-preserve=ownership "$appDir/Contents/Resources" $out/share/chatbox/

    makeWrapper ${lib.getExe electron} $out/bin/chatbox \
      --add-flags $out/share/chatbox/resources/app.asar \
      --set-default ELECTRON_FORCE_IS_PACKAGED 1 \
      --set-default ELECTRON_IS_DEV 0 \
      --inherit-argv0
  ''
  + lib.optionalString stdenv.hostPlatform.isLinux ''
    mkdir -p $out/share/chatbox
    cp -Pr --no-preserve=ownership release/build/*-unpacked/{locales,resources{,.pak}} $out/share/chatbox

    install -Dm644 assets/icon.png $out/share/icons/hicolor/512x512/apps/chatbox.png

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

  desktopItems = lib.optionals stdenv.hostPlatform.isLinux [
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
    inherit (finalAttrs) pnpmDeps;
    updateScript = nix-update-script { extraArgs = [ "--use-github-releases" ]; };
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
