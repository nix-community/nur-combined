{
  lib,
  buildNpmPackage,
  importNpmLock,
  rustPlatform,
  cargo,
  rustc,
  pkg-config,
  alsa-lib,
  electron,
  copyDesktopItems,
  makeDesktopItem,
  makeWrapper,
  nix-update-script,

  sources,
  source ? sources.yaqmc,
}:

buildNpmPackage (finalAttrs: {
  inherit (source) pname src version;

  npmDeps = importNpmLock {
    npmRoot = source.src;
    package = lib.importJSON source.extract."package.json";
    packageLock = lib.importJSON source.extract."package-lock.json";
  };
  npmConfigHook = importNpmLock.npmConfigHook;

  cargoDeps = rustPlatform.importCargoLock source.cargoLock."Cargo.lock";

  env = {
    ELECTRON_SKIP_BINARY_DOWNLOAD = "1";
    PLAYWRIGHT_SKIP_BROWSER_DOWNLOAD = "1";
    YAQMC_RELEASE_CHANNEL = "latest";
    YAQMC_BUILD_COMMIT = finalAttrs.src.rev;
  };

  nativeBuildInputs = [
    cargo
    rustc
    rustPlatform.cargoSetupHook
    pkg-config
    copyDesktopItems
    makeWrapper
  ];

  buildInputs = [
    alsa-lib
  ];

  # Use the application's Nix resource directory instead of
  # the shared Electron runtime's process.resourcesPath.
  # Disable application-managed updates.
  patches = [ ./nix-resources-and-disable-updates.patch ];

  preBuild = ''
    cargo build --release --locked --offline -p yaqmc-core
    npm run stage-core -- --profile release
  '';

  npmBuildScript = "ci:frontend-build";

  postBuild = ''
    npm run build --workspace @yaqmc/desktop

    mkdir -p apps/desktop/electron-dist
    cp -r ${electron.dist}/. apps/desktop/electron-dist/
    chmod -R u+w apps/desktop/electron-dist

    pushd apps/desktop
    npm exec --offline -- electron-builder \
      --projectDir . \
      --config electron-builder.yml \
      --linux --dir --publish never \
      -c.electronDist=electron-dist \
      -c.electronVersion=${electron.version}
    popd
  '';

  installPhase = ''
    runHook preInstall

    mkdir -p "$out/share/yaqmc" "$out/bin"
    cp -r release-electron/linux*-unpacked/resources "$out/share/yaqmc/"
    install -Dm644 apps/desktop/resources/icon.png \
      "$out/share/yaqmc/resources/icon.png"

    for size in 32 64 128; do
      install -Dm644 "apps/desktop/resources/''${size}x''${size}.png" \
        "$out/share/icons/hicolor/''${size}x''${size}/apps/yaqmc.png"
    done

    install -Dm644 apps/desktop/resources/128x128@2x.png "$out/share/icons/hicolor/256x256/apps/yaqmc.png"

    makeWrapper ${lib.getExe electron} "$out/bin/yaqmc" \
      --add-flags "$out/share/yaqmc/resources/app.asar" \
      --set-default ELECTRON_FORCE_IS_PACKAGED 1 \
      --set YAQMC_NIX_RESOURCES "$out/share/yaqmc/resources" \
      --inherit-argv0

    runHook postInstall
  '';

  # Refresh the Core integrity manifest after Nix fixup.
  postFixup = ''
    core="$out/share/yaqmc/resources/core/yaqmc-core"
    test -x "$core"
    digest="$(sha256sum "$core" | cut -d ' ' -f 1)"
    bytes="$(stat -c %s "$core")"

    printf '%s  yaqmc-core\n' "$digest" > "$out/share/yaqmc/resources/core/core.sha256"

    printf '{"name":"yaqmc-core","sha256":"%s","bytes":%s}\n' "$digest" "$bytes" \
      > "$out/share/yaqmc/resources/core/manifest.json"
  '';

  doCheck = false;
  doInstallCheck = true;

  installCheckPhase = ''
    runHook preInstallCheck

    test -f "$out/share/yaqmc/resources/app.asar"
    test -f "$out/share/yaqmc/resources/renderer/index.html"
    test -f "$out/share/yaqmc/resources/contract/methods.json"

    (cd "$out/share/yaqmc/resources/core" && sha256sum -c core.sha256)

    runHook postInstallCheck
  '';

  desktopItems = [
    (makeDesktopItem {
      name = "yaqmc";
      desktopName = "YAQMC";
      comment = finalAttrs.meta.description;
      exec = "yaqmc %U";
      icon = "yaqmc";
      categories = [
        "Audio"
        "AudioVideo"
        "Player"
      ];
      mimeTypes = [ "x-scheme-handler/yaqmc" ];
      startupWMClass = "YAQMC";
    })
  ];

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Unofficial QQ Music client with a native Rust playback core";
    homepage = "https://github.com/YAQMC/YAQMC";
    changelog = "https://github.com/YAQMC/YAQMC/releases/tag/v${finalAttrs.version}";
    license = with lib.licenses; [
      gpl3Plus
      agpl3Only
    ];
    mainProgram = "yaqmc";
  };
})
