{
  lib,
  stdenv,
  fetchFromGitHub,
  fetchYarnDeps,
  yarnConfigHook,
  nodejs,
  yarn,
  rustPlatform,
  cargo,
  rustc,
  pkg-config,
  openssl,
  sqlite,
  electron,
  onnxruntime,
  node-gyp,
  python3,
  makeWrapper,
  copyDesktopItems,
  makeDesktopItem,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "deta-surf";
  version = "1.4.7-beta.0.rc.1";

  src = fetchFromGitHub {
    owner = "deta";
    repo = "surf";
    tag = finalAttrs.version;
    hash = "sha256-UW85VCgjuPFajLPajJ0SgW3RJ57UrKQ/OuXHVCa3AbM=";
  };

  yarnOfflineCache = fetchYarnDeps {
    yarnLock = "${finalAttrs.src}/yarn.lock";
    hash = "sha256-RpNTVG9rBpVOrgFqEj9YbsRQMdVjWYQk7SiWIvwZQ0M=";
  };

  cargoDepsBackend = rustPlatform.importCargoLock {
    lockFile = "${finalAttrs.src}/packages/backend/Cargo.lock";
  };

  cargoDepsServer = rustPlatform.importCargoLock {
    lockFile = "${finalAttrs.src}/packages/backend-server/Cargo.lock";
    outputHashes = {
      "fastembed-3.14.1" = "sha256-Y95XYR+FlDlNHqjID/G7LFfrD815Dns1ZiDTlkrEsgs=";
      "usearch-2.14.0" = "sha256-Gy6J1gnQ1MPlF0Ejh2DP/f5OD1kAiqaKn3IQ20YEjB4=";
    };
  };

  nativeBuildInputs = [
    yarnConfigHook
    nodejs
    yarn
    cargo
    rustc
    node-gyp
    python3
    pkg-config
    makeWrapper
    copyDesktopItems
  ];

  buildInputs = [
    openssl
    sqlite
    onnxruntime
  ];

  env = {
    ELECTRON_SKIP_BINARY_DOWNLOAD = "1";
    OPENSSL_NO_VENDOR = "1";
    ORT_STRATEGY = "system";
    ORT_LIB_LOCATION = "${lib.getLib onnxruntime}/lib";
    npm_config_nodedir = "${electron.headers}";
  };

  preBuild = ''
    mkdir -p packages/backend/.cargo packages/backend-server/.cargo
    ln -s ${finalAttrs.cargoDepsBackend} packages/backend/cargo-vendor-dir
    cp ${finalAttrs.cargoDepsBackend}/.cargo/config.toml packages/backend/.cargo/config.toml
    ln -s ${finalAttrs.cargoDepsServer} packages/backend-server/cargo-vendor-dir
    cp ${finalAttrs.cargoDepsServer}/.cargo/config.toml packages/backend-server/.cargo/config.toml
  '';

  buildPhase = ''
    runHook preBuild

    while IFS= read -r binDir; do
      export PATH="$PWD/$binDir:$PATH"
    done < <(find . -type d -path "*/node_modules/.bin")

    # 1. Build the Rust backend / N-API native addon
    pushd packages/backend
    cargo build --release --offline --frozen
    popd

    # 2. Build all workspace packages (check root/app package.json if script names differ)
    yarn --offline build

    # 3. Package the Electron app unpacked without downloading Electron
    pushd app
    yarn --offline electron-builder --dir \
      -c.electronDist=${electron.dist} \
      -c.electronVersion=${electron.version}
    popd

    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall

    mkdir -p $out/share/surf
    cp -r app/dist/linux-unpacked/resources/* $out/share/surf/

    makeWrapper ${lib.getExe electron} $out/bin/surf \
      --add-flags "$out/share/surf/app.asar" \
      --add-flags "\''${NIXOS_OZONE_WL:+\''${WAYLAND_DISPLAY:+--ozone-platform-hint=auto --enable-features=WaylandWindowDecorations}}" \
      --set-default ELECTRON_FORCE_IS_PACKAGED 1

    install -Dm644 app/resources/icon.png $out/share/icons/hicolor/512x512/apps/surf.png

    runHook postInstall
  '';

  desktopItems = [
    (makeDesktopItem {
      name = "surf";
      desktopName = "Surf";
      comment = "Personal AI Notebooks";
      exec = "surf %U";
      icon = "surf";
      categories = [
        "Office"
        "Utility"
      ];
      startupWMClass = "Surf";
    })
  ];

  passthru.updateSrcipt = ./update.sh;

  meta = {
    description = "Personal AI Notebooks";
    homepage = "https://github.com/deta/surf";
    license = lib.licenses.asl20;
    mainProgram = "surf";
    platforms = [
      "x86_64-linux"
      "aarch64-linux"
    ];
  };
})
