{
  lib,
  stdenv,
  fetchFromGitHub,
  fetchNpmDeps,
  npmHooks,
  nodejs_22,
  makeWrapper,
  copyDesktopItems,
  makeDesktopItem,
  runCommand,
  electron,
  python3,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "chatall";
  version = "1.85.110";

  src = fetchFromGitHub {
    owner = "ai-shifu";
    repo = "ChatALL";
    tag = "v${finalAttrs.version}";
    hash = "sha256-Zz1gYLgrx/oDURR/mke9MnPUR2zdjup+DnUXZNU4fxg=";
  };

  npmDeps = fetchNpmDeps {
    inherit (finalAttrs) pname version;
    src = runCommand "deps-src" { } ''
      mkdir $out
      cp ${./package.json} $out/package.json
      cp ${./package-lock.json} $out/package-lock.json
    '';
    hash = "sha256-6OZYieBTrDp19FzRLXIVV9viqsjanoprTWW0sFarXlE=";
  };

  postPatch = ''
    cp ${./package-lock.json} package-lock.json
    cat >> vue.config.js <<EOF
    const oldConfig = module.exports;
    module.exports = {
      ...oldConfig,
      lintOnSave: false
    };
    EOF

    python3 -c "
    import json
    with open('package.json', 'r') as f:
        data = json.load(f)

    if 'electron-builder' in data.get('dependencies', {}):
        del data['dependencies']['electron-builder']
        if 'devDependencies' not in data:
            data['devDependencies'] = {}
        data['devDependencies']['electron-builder'] = '^25.1.8'

    # Fix main entry point
    if 'main' not in data:
        data['main'] = 'dist_electron/bundled/index.js'
    else:
        # if main exists but was wrong (e.g. background.js), overwrite it or leave it?
        # The prompt says I set it to background.js in previous step.
        # But this script runs on fresh extraction?
        # No, `package.nix` is just updated.
        data['main'] = 'dist_electron/bundled/index.js'

    with open('package.json', 'w') as f:
        json.dump(data, f, indent=2)
    "
  '';

  nativeBuildInputs = [
    nodejs_22
    npmHooks.npmConfigHook
    makeWrapper
    copyDesktopItems
    python3
  ];

  makeCacheWritable = true;

  env.ELECTRON_SKIP_BINARY_DOWNLOAD = 1;

  npmFlags = [ "--legacy-peer-deps" ];

  buildPhase = ''
    runHook preBuild

    npm run electron:build -- \
      --dir \
      -c.electronDist=${electron.dist} \
      -c.electronVersion=${electron.version}

    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall

    mkdir -p $out/share/chatall
    cp -r dist/*-unpacked/{locales,resources{,.pak}} $out/share/chatall

    install -Dm644 src/assets/icon.png \
      $out/share/icons/hicolor/512x512/apps/chatall.png

    makeWrapper ${lib.getExe electron} $out/bin/chatall \
      --add-flags $out/share/chatall/resources/app.asar \
      --add-flags "\''${NIXOS_OZONE_WL:+\''${WAYLAND_DISPLAY:+--ozone-platform-hint=auto --enable-features=WaylandWindowDecorations --enable-wayland-ime=true}}" \
      --set-default ELECTRON_FORCE_IS_PACKAGED 1 \
      --set-default ELECTRON_IS_DEV 0 \
      --inherit-argv0

    runHook postInstall
  '';

  desktopItems = [
    (makeDesktopItem {
      name = "chatall";
      exec = "chatall %U";
      icon = "chatall";
      desktopName = "ChatALL";
      comment = finalAttrs.meta.description;
      categories = [
        "Network"
        "Chat"
      ];
      startupWMClass = "ChatALL";
    })
  ];

  meta = {
    description = "Chat with multiple AI bots and discover the best";
    homepage = "https://github.com/ai-shifu/ChatALL";
    license = lib.licenses.asl20;
    mainProgram = "chatall";
    platforms = lib.platforms.linux;
  };
})
