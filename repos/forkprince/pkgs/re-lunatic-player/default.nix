{
  electron,
  nodejs,
  pnpm_10_29_2,
  stdenvNoCC,
  autoPatchelfHook,
  copyDesktopItems,
  makeDesktopItem,
  makeWrapper,
  pnpmConfigHook,
  fetchPnpmDeps,
  fetchFromGitHub,
  alsa-lib,
  gtk3,
  mesa,
  nss,
  libx11,
  libpulseaudio,
  libxslt,
  lib,
}:
stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "re-lunatic-player";
  version = "1.2.1";
  src = fetchFromGitHub {
    owner = "Prince527Github";
    repo = "Re-Lunatic-Player";
    rev = "v${finalAttrs.version}";
    hash = "sha256-E+m0hzufdUT0tXnQuXrxeaaFXkSLfFr+0NAy9f7ZTzs=";
  };

  nativeBuildInputs =
    [
      makeWrapper
      pnpmConfigHook
      pnpm_10_29_2
      nodejs
    ]
    ++ lib.optionals stdenvNoCC.hostPlatform.isLinux [
      autoPatchelfHook
      copyDesktopItems
    ];

  buildInputs =
    [electron]
    ++ lib.optionals stdenvNoCC.hostPlatform.isLinux [
      alsa-lib
      gtk3
      mesa
      nss

      libpulseaudio
      libxslt

      libx11
    ];

  env = {
    ELECTRON_SKIP_BINARY_DOWNLOAD = 1;
    CI = 1; # makes the logs more readable during builds
    npm_config_node_linker = "hoisted";
    pnpm_config_node_linker = "hoisted";
  };

  desktopItems = lib.optionals stdenvNoCC.hostPlatform.isLinux [
    (makeDesktopItem {
      name = finalAttrs.pname;
      desktopName = "Re:Lunatic Player";
      exec = finalAttrs.pname;
      icon = finalAttrs.pname;
      startupNotify = true;
      startupWMClass = "Re:Lunatic Player";
      terminal = false;
      genericName = "Radio Player";
      keywords = [
        "radio"
        "touhou"
        "lunatic"
        "player"
        "music"
      ];
      categories = [
        "Audio"
        "AudioVideo"
      ];
    })
  ];

  pnpmDeps = fetchPnpmDeps {
    inherit (finalAttrs) pname version src;
    pnpm = pnpm_10_29_2;
    fetcherVersion = 3;
    hash = "sha256-BHcHLDE4KBVWrG1Jevg9OPq/xdaN1PdtIfoqzDKDGYY=";
  };

  buildPhase = ''
    export npm_config_nodedir=${electron.headers}

    mkdir -p out/Re-Lunatic-Player-linux-x64/resources
    node node_modules/@electron/asar/bin/asar.js pack . \
      out/Re-Lunatic-Player-linux-x64/resources/app.asar \
      --unpack "*.{node,dll}" \
      --unpack-dir "{node_modules/**/*.node,node_modules/**/*.dll}"
  '';

  installPhase =
    if stdenvNoCC.hostPlatform.isLinux
    then ''
      mkdir -p $out/share
      cp -r out/*/resources "$out/share/"

      makeWrapper ${lib.getExe electron} $out/bin/re-lunatic-player \
        --add-flags $out/share/resources/app.asar \
        --set ELECTRON_FORCE_IS_PACKAGED 1 \
        --inherit-argv0

      install -Dm644 src/img/logo.png $out/share/icons/hicolor/256x256/apps/re-lunatic-player.png

      runHook postInstall
    ''
    else ''
      APP="$out/Applications/Re-Lunatic-Player.app"
      mkdir -p "$out/Applications"

      cp -pr "${electron}/Applications/Electron.app" "$APP"
      chmod -R u+w "$APP"

      cp src/img/logo.icns "$APP/Contents/Resources/electron.icns"
      rm -f "$APP/Contents/Resources/default_app.asar"
      cp -r out/*/resources/. "$APP/Contents/Resources/"

      cat > "$APP/Contents/Info.plist" <<EOF
      <?xml version="1.0" encoding="UTF-8"?>
      <!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
      <plist version="1.0">
      <dict>
        <key>CFBundleName</key>
        <string>Re:Lunatic Player</string>
        <key>CFBundleDisplayName</key>
        <string>Re:Lunatic Player</string>
        <key>CFBundleExecutable</key>
        <string>Electron</string>
        <key>CFBundleIdentifier</key>
        <string>com.${finalAttrs.pname}</string>
        <key>CFBundleIconFile</key>
        <string>electron.icns</string>
      </dict>
      </plist>
      EOF

      mkdir -p $out/bin
      ln -s "$APP/Contents/MacOS/Electron" $out/bin/${finalAttrs.pname}

      runHook postInstall
    '';

  meta = {
    description = "Music player for Gensokyo Radio";
    homepage = "https://github.com/Prince527Github/Re-Lunatic-Player";
    license = lib.licenses.agpl3Plus;
    maintainers = with lib.maintainers; [
      Prinky
      LMacrini
    ];
    platforms = with lib.platforms; linux ++ darwin;
    mainProgram = finalAttrs.pname;
  };
})
