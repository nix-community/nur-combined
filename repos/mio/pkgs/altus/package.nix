{
  lib,
  stdenv,
  fetchFromGitHub,
  makeDesktopItem,
  copyDesktopItems,
  makeWrapper,
  electron_39,
  yarn-berry_4,
  nodejs,
  zip,
  writableTmpDirAsHomeHook,
}:

let
  electron = electron_39;
  yarn-berry = yarn-berry_4;
in
stdenv.mkDerivation (finalAttrs: {
  pname = "altus";
  version = "5.7.2";

  src = fetchFromGitHub {
    owner = "amanharwara";
    repo = "altus";
    tag = finalAttrs.version;
    hash = "sha256-cQMi2t0E1EtpGt6/4WZ/Wbgy2tYhZbPmUkKNclQWD4I=";
  };

  missingHashes = ./missing-hashes.json;

  offlineCache = yarn-berry.fetchYarnBerryDeps {
    inherit (finalAttrs) src missingHashes;
    hash = "sha256-J1jTh3St2t4UiANM043raL/iSU3313aXAoP0oQnzKGE=";
  };

  nativeBuildInputs = [
    makeWrapper
    copyDesktopItems
    yarn-berry
    yarn-berry.yarnBerryConfigHook
    writableTmpDirAsHomeHook
    nodejs
    (nodejs.python.withPackages (ps: with ps; [ setuptools ]))
    zip
  ];

  env = {
    ELECTRON_SKIP_BINARY_DOWNLOAD = "1";
  };

  buildPhase = ''
    runHook preBuild

    cp -r "${electron.dist}" electron-dist
    chmod -R u+w electron-dist
    pushd electron-dist
    zip -0Xqr ../electron.zip .
    popd
    rm -rf electron-dist

    substituteInPlace node_modules/@electron/packager/dist/packager.js \
      --replace-fail "await this.getElectronZipPath(downloadOpts)" "\"$(pwd)/electron.zip\""

    mkdir -p "$HOME/.electron-dist"
    cp -r "${electron.dist}/." "$HOME/.electron-dist/"
    chmod -R u+w "$HOME/.electron-dist"

    export ELECTRON_OVERRIDE_DIST_PATH="$HOME/.electron-dist"

    yarn run package

    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall

    app_dir="out/Altus-linux-x64"
    if [ -d "out/Altus-linux-arm64" ]; then
      app_dir="out/Altus-linux-arm64"
    fi

    mkdir -p "$out/opt/altus"
    cp -r "$app_dir/resources" "$out/opt/altus/"

    install -Dm644 public/assets/icons/icon.png \
      "$out/share/icons/hicolor/256x256/apps/altus.png"

    makeWrapper ${lib.getExe electron} "$out/bin/altus" \
      --add-flags "$out/opt/altus/resources/app" \
      --add-flags "\''${NIXOS_OZONE_WL:+\''${WAYLAND_DISPLAY:+--ozone-platform-hint=auto --enable-features=WaylandWindowDecorations --enable-wayland-ime=true --wayland-text-input-version=3}}" \
      --set-default ELECTRON_FORCE_IS_PACKAGED 1 \
      --set-default ELECTRON_IS_DEV 0

    runHook postInstall
  '';

  desktopItems = [
    (makeDesktopItem {
      name = "altus";
      desktopName = "Altus";
      comment = "Desktop client for WhatsApp Web with themes and multiple account support";
      exec = "altus";
      icon = "altus";
      categories = [
        "Network"
        "Chat"
      ];
    })
  ];

  meta = {
    description = "Desktop client for WhatsApp Web with themes and multiple account support";
    homepage = "https://github.com/amanharwara/altus";
    license = lib.licenses.gpl3Only;
    mainProgram = "altus";
    platforms = [
      "x86_64-linux"
      "aarch64-linux"
    ];
  };
})
