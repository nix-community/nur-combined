{
  lib,
  stdenv,
  fetchFromGitHub,
  fetchPnpmDeps,
  fetchNpmDeps,
  pnpmConfigHook,
  pnpm_10,
  nodejs_22,
  python3,
  electron,
  makeWrapper,
  copyDesktopItems,
  makeDesktopItem,
  autoPatchelfHook,
  writableTmpDirAsHomeHook,
}:

let
  pnpm = pnpm_10;
  nodejs = nodejs_22;
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

  appNpmDeps = fetchNpmDeps {
    name = "chatbox-app-npm-deps-${finalAttrs.version}";
    src = "${finalAttrs.src}/release/app";
    hash = "sha256-TsHwflraAWtLYb/dH8+nDv+AAfh9/zND6a8nzfbI0qg=";
  };

  nativeBuildInputs = [
    nodejs
    python3
    pnpm
    pnpmConfigHook
    makeWrapper
    copyDesktopItems
    writableTmpDirAsHomeHook
  ]
  ++ lib.optionals stdenv.hostPlatform.isLinux [ autoPatchelfHook ];

  dontAutoPatchelf = true;
  dontCheckForBrokenSymlinks = true;

  env = {
    ELECTRON_SKIP_BINARY_DOWNLOAD = "1";
    NODE_ENV = "production";
    HUSKY = "0";
    NPM_CONFIG_MANAGE_PACKAGE_MANAGER_VERSIONS = "false";
    npm_config_engine_strict = "false";
    CHATBOX_BUILD_PLATFORM = if stdenv.hostPlatform.isDarwin then "darwin" else "linux";
    CHATBOX_BUILD_TARGET = "desktop";
    UPDATE_CHANNEL = "nix";
  };

  postPatch = ''
    substituteInPlace .npmrc \
      --replace-fail 'engine-strict=true' 'engine-strict=false'

    substituteInPlace package.json \
      --replace-fail '"packageManager": "pnpm@10.33.0+sha512.10568bb4a6afb58c9eb3630da90cc9516417abebd3fabbe6739f0ae795728da1491e9db5a544c76ad8eb7570f5c4bb3d6c637b2cb41bfdcdb47fa823c8649319"' \
        '"_packageManager": "pnpm@10.33.0"'

    # Align the nested app lockfile with package.json so npm ci can run offline.
    python3 -c '
    import json
    from pathlib import Path
    pkg = json.loads(Path("release/app/package.json").read_text())
    lock = json.loads(Path("release/app/package-lock.json").read_text())
    lock["name"] = pkg["name"]
    lock["version"] = pkg["version"]
    root = lock.get("packages", {}).get("", {})
    root["name"] = pkg["name"]
    root["version"] = pkg["version"]
    lock.setdefault("packages", {})[""] = root
    Path("release/app/package-lock.json").write_text(json.dumps(lock, indent=2) + "\n")
    '
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

    # Prefer packaged resource lookup even when wrapping nixpkgs electron.
    python3 - <<'PY'
    from pathlib import Path
    main = Path("release/app/dist/main/main.js")
    text = main.read_text()
    old_res = "process.resourcesPath"
    new_res = 'require("path").join(require("electron").app.getAppPath(), "..", "resources")'
    if old_res not in text:
        raise SystemExit("process.resourcesPath not found in bundled main.js")
    text = text.replace(old_res, new_res)
    text = text.replace("process.defaultApp", "false")
    main.write_text(text)
    PY

    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall

    appdir="$out/share/chatbox"
    mkdir -p "$appdir/app" "$appdir/resources/assets" "$appdir/resources/ripgrep"

    cp release/app/package.json "$appdir/app/"
    cp -r release/app/dist "$appdir/app/dist"
    cp -a release/app/node_modules "$appdir/app/node_modules"

    cp -r assets/. "$appdir/resources/assets/"

    rg_src=""
    for candidate in \
      node_modules/@vscode/ripgrep-universal/bin/linux-${
        if stdenv.hostPlatform.isAarch64 then "arm64" else "x64"
      }/rg \
      node_modules/@vscode/ripgrep-universal/bin/darwin-${
        if stdenv.hostPlatform.isAarch64 then "arm64" else "x64"
      }/rg
    do
      if [ -f "$candidate" ]; then
        rg_src="$candidate"
        break
      fi
    done
    if [ -z "$rg_src" ]; then
      echo "error: bundled ripgrep binary not found"
      find node_modules/@vscode/ripgrep-universal -type f 2>/dev/null || true
      exit 1
    fi
    cp "$rg_src" "$appdir/resources/ripgrep/rg"
    chmod +x "$appdir/resources/ripgrep/rg"
    if [ -f node_modules/@vscode/ripgrep-universal/LICENSE ]; then
      cp node_modules/@vscode/ripgrep-universal/LICENSE "$appdir/resources/ripgrep/LICENSE.vscode-ripgrep"
    fi

    ${lib.optionalString stdenv.hostPlatform.isLinux ''
      autoPatchelf "$appdir/app/node_modules" "$appdir/resources/ripgrep/rg" || true
    ''}

    install -Dm644 assets/icon.png "$out/share/icons/hicolor/512x512/apps/chatbox.png"

    makeWrapper ${lib.getExe electron} "$out/bin/chatbox" \
      --add-flags "$appdir/app" \
      --add-flags "\''${NIXOS_OZONE_WL:+\''${WAYLAND_DISPLAY:+--ozone-platform-hint=auto --enable-features=WaylandWindowDecorations --enable-wayland-ime=true}}" \
      --set-default ELECTRON_FORCE_IS_PACKAGED 1 \
      --set-default ELECTRON_IS_DEV 0 \
      --inherit-argv0

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

  meta = {
    description = "Desktop client for ChatGPT, Claude, and other LLMs";
    homepage = "https://github.com/chatboxai/chatbox";
    changelog = "https://github.com/chatboxai/chatbox/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.gpl3Only;
    mainProgram = "chatbox";
    platforms = [
      "x86_64-linux"
      "aarch64-linux"
    ];
    sourceProvenance = [ lib.sourceTypes.fromSource ];
  };
})
