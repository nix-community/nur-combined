{
  lib,
  stdenv,
  fetchFromGitHub,
  fetchYarnDeps,
  buildEnv,
  nodejs_24,
  yarn,
  yarnConfigHook,
  fixup-yarn-lock,
  electron_43,
  nix-update,
  writeShellApplication,
  makeWrapper,
  makeDesktopItem,
  copyDesktopItems,
  autoPatchelfHook,
  writableTmpDirAsHomeHook,
  python3,
  node-gyp,
  pkg-config,
  git,

  libsecret,
  fontconfig,
  libx11,
  libxcomposite,
  libxdamage,
  libxrandr,
  libxtst,
  nss,
  nspr,
  alsa-lib,
  gtk3,
  cups,
  dbus,
  expat,
  pango,
  cairo,
  libgbm,
}:

let
  electron = electron_43;
  nodejs = nodejs_24;
  isDarwin = stdenv.hostPlatform.isDarwin;
  isLinux = stdenv.hostPlatform.isLinux;
  electronArch = if stdenv.hostPlatform.isAarch64 then "arm64" else "x64";

  yarnDependencyAttrs = [
    "rootYarnDeps"
    "appYarnDeps"
    "webYarnDeps"
    "autoSudoPasswordYarnDeps"
    "communityColorSchemesYarnDeps"
    "coreYarnDeps"
    "electronPluginYarnDeps"
    "linkifierYarnDeps"
    "localYarnDeps"
    "pluginManagerYarnDeps"
    "serialYarnDeps"
    "settingsYarnDeps"
    "sshYarnDeps"
    "telnetYarnDeps"
    "terminalYarnDeps"
    "tabbyWebYarnDeps"
    "webDemoYarnDeps"
  ];
in
stdenv.mkDerivation (finalAttrs: {
  pname = "tabby-terminal";
  version = "1.0.238";

  src = fetchFromGitHub {
    owner = "Eugeny";
    repo = "tabby";
    tag = "v${finalAttrs.version}";
    hash = "sha256-cSkxy195qkw2yK81COmGNnuOgCo7j6TXsVZYF1TMvjk=";
  };

  patches = [ ./source.patch ];

  __structuredAttrs = true;
  strictDeps = true;

  nativeBuildInputs = [
    nodejs
    yarn
    yarnConfigHook
    fixup-yarn-lock
    writableTmpDirAsHomeHook
    python3
    node-gyp
    pkg-config
    git
    makeWrapper
  ]
  ++ lib.optionals isLinux [
    autoPatchelfHook
    copyDesktopItems
  ];

  buildInputs = lib.optionals isLinux [
    libsecret
    fontconfig
    libx11
    libxcomposite
    libxdamage
    libxrandr
    libxtst
    nss
    nspr
    alsa-lib
    gtk3
    cups
    dbus
    expat
    pango
    cairo
    libgbm
  ];

  env = {
    ELECTRON_SKIP_BINARY_DOWNLOAD = "1";
    CSC_IDENTITY_AUTO_DISCOVERY = "false";
    MACOSX_DEPLOYMENT_TARGET = "11.0";
    npm_config_build_from_source = "true";
    npm_config_macosx_deployment_target = "11.0";
    npm_config_nodedir = electron.headers;
    TABBY_VERSION = finalAttrs.version;
  };

  # The repository has one lockfile per plugin, while upstream's installer
  # invokes Yarn independently in each package. A combined offline mirror lets
  # those scripts run unchanged.
  dontYarnInstallDeps = true;
  configurePhase = ''
    runHook preConfigure

    yarnOfflineCache="${finalAttrs.passthru.rootYarnDeps}" runHook yarnConfigHook

    yarn config --offline set yarn-offline-mirror "${finalAttrs.passthru.offlineCache}"
    node scripts/install-deps.mjs

    while IFS= read -r -d "" directory; do
      patchShebangs "$directory"
    done < <(find . -type d -name node_modules -prune -print0)

    yarn --cwd app patch-package
    yarn --cwd web patch-package
    yarn --cwd tabby-terminal patch-package

    ${lib.optionalString isDarwin ''
      for file in \
        app/node_modules/fontmanager-redux/binding.gyp \
        app/node_modules/keytar/binding.gyp \
        app/node_modules/node-addon-api/except.gypi \
        app/node_modules/node-addon-api/noexcept.gypi; do
        substituteInPlace "$file" \
          --replace-fail "'MACOSX_DEPLOYMENT_TARGET': '10.7'" "'MACOSX_DEPLOYMENT_TARGET': '11.0'"
      done
      substituteInPlace app/node_modules/macos-native-processlist/binding.gyp \
        --replace-fail '"MACOSX_DEPLOYMENT_TARGET": "10.7"' '"MACOSX_DEPLOYMENT_TARGET": "11.0"'
      substituteInPlace app/node_modules/node-pty/binding.gyp \
        --replace-fail '"MACOSX_DEPLOYMENT_TARGET":"10.7"' '"MACOSX_DEPLOYMENT_TARGET":"11.0"'
    ''}

    node scripts/build-native.mjs

    runHook postConfigure
  '';

  buildPhase = ''
    runHook preBuild

    yarn run build
    node scripts/prepackage-plugins.mjs

    cp -R "${electron.dist}" electron-dist
    chmod -R u+w electron-dist

    node node_modules/electron-builder/out/cli/cli.js \
      --dir \
      --${if isDarwin then "mac" else "linux"} \
      ${lib.optionalString isDarwin "--${electronArch}"} \
      --config electron-builder.yml \
      -c.electronDist="$PWD/electron-dist" \
      -c.electronVersion=${electron.version} \
      -c.npmRebuild=false \
      -c.extraMetadata.version=${finalAttrs.version} \
      -c.publish=never \
      -c.mac.identity=null \
      -c.mac.notarize=false

    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall
  ''
  + lib.optionalString isDarwin ''
    appDir="$(find dist -maxdepth 3 -type d -name Tabby.app -print -quit)"
    if [ -z "$appDir" ]; then
      echo "error: Tabby.app was not produced" >&2
      find dist -maxdepth 3 -type d || true
      exit 1
    fi

    mkdir -p $out/Applications $out/bin
    cp -R "$appDir" $out/Applications/
    ln -s ../Applications/Tabby.app/Contents/MacOS/Tabby $out/bin/tabby
  ''
  + lib.optionalString isLinux ''
    mkdir -p $out/share/tabby
    cp -R dist/linux-unpacked/resources $out/share/tabby/

    makeWrapper ${lib.getExe electron} $out/bin/tabby \
      --add-flags $out/share/tabby/resources/app.asar \
      --add-flags "\''${NIXOS_OZONE_WL:+\''${WAYLAND_DISPLAY:+--ozone-platform-hint=auto --enable-features=WaylandWindowDecorations --enable-wayland-ime=true --wayland-text-input-version=3}}" \
      --set-default ELECTRON_FORCE_IS_PACKAGED 1 \
      --set-default ELECTRON_IS_DEV 0 \
      --set TABBY_BUILTIN_PLUGINS $out/share/tabby/resources/builtin-plugins \
      --inherit-argv0

    for size in 16 32 64 128 256 512; do
      install -Dm644 "build/icons/''${size}x''${size}.png" \
        "$out/share/icons/hicolor/''${size}x''${size}/apps/tabby-terminal.png"
    done
  ''
  + ''
    runHook postInstall
  '';

  desktopItems = lib.optionals isLinux [
    (makeDesktopItem {
      name = "tabby-terminal";
      desktopName = "Tabby";
      genericName = "Terminal Emulator";
      comment = finalAttrs.meta.description;
      exec = "tabby %U";
      icon = "tabby-terminal";
      categories = [
        "Utility"
        "TerminalEmulator"
        "System"
      ];
      keywords = [
        "terminal"
        "ssh"
        "serial"
      ];
      startupWMClass = "tabby";
      mimeTypes = [ "x-scheme-handler/tabby" ];
    })
  ];

  doInstallCheck = true;
  installCheckPhase = ''
    runHook preInstallCheck
    test -x $out/bin/tabby
  ''
  + lib.optionalString isDarwin ''
    test -f $out/Applications/Tabby.app/Contents/Resources/app.asar
    test -f $out/Applications/Tabby.app/Contents/Resources/app.asar.unpacked/node_modules/node-pty/build/Release/pty.node
  ''
  + lib.optionalString isLinux ''
    test -f $out/share/tabby/resources/app.asar
    test -f $out/share/tabby/resources/builtin-plugins/tabby-core/package.json
    test -f $out/share/tabby/resources/app.asar.unpacked/node_modules/node-pty/build/Release/pty.node
  ''
  + ''
    runHook postInstallCheck
  '';

  passthru =
    let
      rootYarnDeps = fetchYarnDeps {
        name = "tabby-terminal-${finalAttrs.version}-yarn-deps-root";
        yarnLock = finalAttrs.src + "/yarn.lock";
        hash = "sha256-Nlocf9BzCHVCdFkhM7v1Bx0Vp4V29b0XoP/xMXR7ukM=";
      };
      appYarnDeps = fetchYarnDeps {
        name = "tabby-terminal-${finalAttrs.version}-yarn-deps-app";
        yarnLock = finalAttrs.src + "/app/yarn.lock";
        hash = "sha256-0skA50yr7IK8mDqjhkgeKXeCK/VM2gDtd2FTWiLPmBI=";
      };
      webYarnDeps = fetchYarnDeps {
        name = "tabby-terminal-${finalAttrs.version}-yarn-deps-web";
        yarnLock = finalAttrs.src + "/web/yarn.lock";
        hash = "sha256-V10UNfOws0nmTcZau82+gt2VE/ce4lwkOHdFP/rCzAU=";
      };
      autoSudoPasswordYarnDeps = fetchYarnDeps {
        name = "tabby-terminal-${finalAttrs.version}-yarn-deps-auto-sudo-password";
        yarnLock = finalAttrs.src + "/tabby-auto-sudo-password/yarn.lock";
        hash = "sha256-ESlEso/uSoaKnG5hB/FGVxaymhKafEVzokNpfJ/lo7Y=";
      };
      communityColorSchemesYarnDeps = fetchYarnDeps {
        name = "tabby-terminal-${finalAttrs.version}-yarn-deps-community-color-schemes";
        yarnLock = finalAttrs.src + "/tabby-community-color-schemes/yarn.lock";
        hash = "sha256-oZgyP0hTU9bxszOVg3Bmiu6yos2d2Inc1Do8To4z8GQ=";
      };
      coreYarnDeps = fetchYarnDeps {
        name = "tabby-terminal-${finalAttrs.version}-yarn-deps-core";
        yarnLock = finalAttrs.src + "/tabby-core/yarn.lock";
        hash = "sha256-FdyYS/aK2jRsZWDQnCGY7rixEl0uAhfWEABOZxG96Ug=";
      };
      electronPluginYarnDeps = fetchYarnDeps {
        name = "tabby-terminal-${finalAttrs.version}-yarn-deps-electron";
        yarnLock = finalAttrs.src + "/tabby-electron/yarn.lock";
        hash = "sha256-uXnvs+yE9q/Je5Jb4IK/5hLYXhqh5Ev8eIZCKVqhkpA=";
      };
      linkifierYarnDeps = fetchYarnDeps {
        name = "tabby-terminal-${finalAttrs.version}-yarn-deps-linkifier";
        yarnLock = finalAttrs.src + "/tabby-linkifier/yarn.lock";
        hash = "sha256-5wzCnybxh1231d6psQtvRwmZNRvmEJouWfaR9zbDtkY=";
      };
      localYarnDeps = fetchYarnDeps {
        name = "tabby-terminal-${finalAttrs.version}-yarn-deps-local";
        yarnLock = finalAttrs.src + "/tabby-local/yarn.lock";
        hash = "sha256-bUdepzM/aCiuFKXveQtfGAjH88SqVLqLg+w/vWacIXA=";
      };
      pluginManagerYarnDeps = fetchYarnDeps {
        name = "tabby-terminal-${finalAttrs.version}-yarn-deps-plugin-manager";
        yarnLock = finalAttrs.src + "/tabby-plugin-manager/yarn.lock";
        hash = "sha256-TvYSH9YRKaAKvqUFpzgZLIgbgFgIYv3cjvihVX6uNnE=";
      };
      serialYarnDeps = fetchYarnDeps {
        name = "tabby-terminal-${finalAttrs.version}-yarn-deps-serial";
        yarnLock = finalAttrs.src + "/tabby-serial/yarn.lock";
        hash = "sha256-9+TEApG/UQ32RSfM4lPW+uGiGrMdEU4NZN+JwUFLEM4=";
      };
      settingsYarnDeps = fetchYarnDeps {
        name = "tabby-terminal-${finalAttrs.version}-yarn-deps-settings";
        yarnLock = finalAttrs.src + "/tabby-settings/yarn.lock";
        hash = "sha256-R8HnN5QijE338xE2lV4Z7Ef7Lt0fu8IbqEu4c933jNg=";
      };
      sshYarnDeps = fetchYarnDeps {
        name = "tabby-terminal-${finalAttrs.version}-yarn-deps-ssh";
        yarnLock = finalAttrs.src + "/tabby-ssh/yarn.lock";
        hash = "sha256-XFzVWdpTJJteLz88glTiFmgfZOQRNDmrxc1y2oCMjlk=";
      };
      telnetYarnDeps = fetchYarnDeps {
        name = "tabby-terminal-${finalAttrs.version}-yarn-deps-telnet";
        yarnLock = finalAttrs.src + "/tabby-telnet/yarn.lock";
        hash = "sha256-9+TEApG/UQ32RSfM4lPW+uGiGrMdEU4NZN+JwUFLEM4=";
      };
      terminalYarnDeps = fetchYarnDeps {
        name = "tabby-terminal-${finalAttrs.version}-yarn-deps-terminal";
        yarnLock = finalAttrs.src + "/tabby-terminal/yarn.lock";
        hash = "sha256-bZ4cVQJkmL7tWgxuGkFT2/qsUhwBsjkrJsUwhltb//o=";
      };
      tabbyWebYarnDeps = fetchYarnDeps {
        name = "tabby-terminal-${finalAttrs.version}-yarn-deps-tabby-web";
        yarnLock = finalAttrs.src + "/tabby-web/yarn.lock";
        hash = "sha256-BosGjjNq7KfYH+JSV8AldxsoIqX2GEDpNEgTiNm9pcc=";
      };
      webDemoYarnDeps = fetchYarnDeps {
        name = "tabby-terminal-${finalAttrs.version}-yarn-deps-web-demo";
        yarnLock = finalAttrs.src + "/tabby-web-demo/yarn.lock";
        hash = "sha256-LiOM/dUNN5hu2+kJfyXPQsLWsXHvfJT8dSVRyWOCt38=";
      };
      offlineCache = buildEnv {
        name = "tabby-terminal-${finalAttrs.version}-yarn-offline-cache";
        paths = [
          rootYarnDeps
          appYarnDeps
          webYarnDeps
          autoSudoPasswordYarnDeps
          communityColorSchemesYarnDeps
          coreYarnDeps
          electronPluginYarnDeps
          linkifierYarnDeps
          localYarnDeps
          pluginManagerYarnDeps
          serialYarnDeps
          settingsYarnDeps
          sshYarnDeps
          telnetYarnDeps
          terminalYarnDeps
          tabbyWebYarnDeps
          webDemoYarnDeps
        ];
        ignoreCollisions = true;
      };
    in
    {
      inherit
        rootYarnDeps
        appYarnDeps
        webYarnDeps
        autoSudoPasswordYarnDeps
        communityColorSchemesYarnDeps
        coreYarnDeps
        electronPluginYarnDeps
        linkifierYarnDeps
        localYarnDeps
        pluginManagerYarnDeps
        serialYarnDeps
        settingsYarnDeps
        sshYarnDeps
        telnetYarnDeps
        terminalYarnDeps
        tabbyWebYarnDeps
        webDemoYarnDeps
        offlineCache
        ;
      updateScript = writeShellApplication {
        name = "update-tabby-terminal";
        runtimeInputs = [ nix-update ];
        text = ''
            export UPDATE_NIX_ATTR_PATH="tabby-terminal"
            nix-update "$@" "$UPDATE_NIX_ATTR_PATH"
          for dependency in ${lib.concatStringsSep " " yarnDependencyAttrs}; do
              nix-update --no-src --subpackage="$dependency" "$UPDATE_NIX_ATTR_PATH"
            done
        '';
      };
    };

  meta = {
    description = "Highly configurable terminal emulator, SSH and serial client";
    homepage = "https://tabby.sh";
    downloadPage = "https://github.com/Eugeny/tabby/releases";
    changelog = "https://github.com/Eugeny/tabby/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.mit;
    mainProgram = "tabby";
    platforms = [
      "x86_64-linux"
      "aarch64-linux"
    ]
    ++ lib.platforms.darwin;
    sourceProvenance = with lib.sourceTypes; [
      fromSource
      binaryNativeCode
    ];
  };
})
