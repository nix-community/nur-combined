{
  lib,
  buildNpmPackage,
  cmake,
  copyDesktopItems,
  electron,
  fetchFromGitHub,
  icoutils,
  makeDesktopItem,
  makeWrapper,
  nix-update-script,
  pngquant,
  udev,
}:

buildNpmPackage (finalAttrs: {
  pname = "eez-studio";
  version = "0.29.0";

  src = fetchFromGitHub {
    owner = "eez-open";
    repo = "studio";
    tag = "v${finalAttrs.version}";
    hash = "sha256-dYVIUBQ++hkyI6gzpwE2KTXo3tfKid4yfs8IZ+jm20w=";
  };

  npmDepsHash = "sha256-vKyitP5xrUZMMZF8D+e5Z4rwc9Y2iS+S56oV62GHkz0=";

  env = {
    ELECTRON_SKIP_BINARY_DOWNLOAD = "1";
    npm_config_build_from_source = "true";
  };

  npmFlags = [
    "--nodedir=${electron.headers}" # better-sqlite3 needs to be built against electron's ABI
  ];

  # pngquant-bin otherwise tries to download a prebuilt binary during npm rebuild.
  npmRebuildFlags = [ "--ignore-scripts" ];

  makeCacheWritable = true;

  nativeBuildInputs = [
    cmake
    copyDesktopItems
    icoutils
    makeWrapper
  ];

  dontUseCmakeConfigure = true; # cmake is used to build a dependency

  buildInputs = [
    udev
  ];

  postPatch = ''
    # Workaround for https://github.com/electron/electron/issues/31121
    substituteInPlace packages/project-editor/flow/expression/parser.ts \
      --replace-fail 'process.resourcesPath!' "'$out/share/eez-studio/resources'"
    substituteInPlace packages/project-editor/lvgl/build.ts \
      --replace-fail 'process.resourcesPath!' "'$out/share/eez-studio/resources'"
    substituteInPlace packages/project-editor/lvgl/docker-build/build-manager.ts \
      --replace-fail 'process.resourcesPath' "'$out/share/eez-studio/resources'"
  '';

  preBuild = ''
    install -Dm755 ${lib.getExe pngquant} node_modules/pngquant-bin/vendor/pngquant
    npm rebuild ${lib.escapeShellArgs finalAttrs.npmFlags}
  '';

  postBuild = ''
    npm exec electron-builder -- \
      --linux \
      --dir \
      --config.electronDist=${electron.dist} \
      --config.electronVersion=${electron.version} \
    ;
  '';

  installPhase = ''
    runHook preInstall

    mkdir -p $out/share/eez-studio $out/bin
    cp -r dist/*-unpacked/{locales,resources{,.pak}} $out/share/eez-studio

    makeWrapper ${lib.getExe electron} $out/bin/eez-studio \
      --add-flags $out/share/eez-studio/resources/app.asar \
      --add-flags "\''${NIXOS_OZONE_WL:+\''${WAYLAND_DISPLAY:+--ozone-platform-hint=auto --enable-features=WaylandWindowDecorations --enable-wayland-ime=true}}" \
      --inherit-argv0

    install -Dm644 ${./mime-info.xml} $out/share/mime/packages/eez-studio.xml

    icotool -x icon.ico
    for f in icon_*.png; do
      res=$(basename "$f" ".png" | cut -d"_" -f3 | cut -d"x" -f1-2)
      install -Dm644 "$f" "$out/share/icons/hicolor/$res/apps/eez-studio.png"
    done;

    runHook postInstall
  '';

  # https://github.com/eez-open/studio/blob/master/installation/make-electron-builder-yml.ts
  desktopItems = [
    (makeDesktopItem {
      name = finalAttrs.pname;
      desktopName = "EEZ Studio";
      exec = "eez-studio %U";
      terminal = false;
      type = "Application";
      icon = "eez-studio";
      startupWMClass = "EEZ Studio";
      comment = "EEZ Studio is a free and open source cross-platform low-code tool for embedded GUIs. Built-in EEZ Flow enables the creation of complex scenarios for test and measurement automation, and the Instruments feature offers remote control of multiple T&M equipment.";
      mimeTypes = [
        "application/x-eez-project"
        "application/x-eez-dashboard"
      ];
      categories = [
        "Utility"
      ];
    })
  ];

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Cross-platform low-code GUI and automation tool for embedded systems and T&M equipment";
    homepage = "https://www.envox.eu/studio/studio-introduction/";
    changelog = "https://github.com/eez-open/studio/releases/tag/${finalAttrs.src.tag}";
    license = lib.licenses.gpl3Only;
    maintainers = with lib.maintainers; [ ilkecan ];
    platforms = lib.platforms.linux;
    mainProgram = "eez-studio";
  };
})
