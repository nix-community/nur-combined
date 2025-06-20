{
  sources,
  hash,
  lib,
  stdenv,
  pnpm,
  nodejs,
  electron,
  makeWrapper,
  copyDesktopItems,
  makeDesktopItem,
}:
stdenv.mkDerivation (final: {
  inherit (sources) pname version src;

  pnpmDeps = pnpm.fetchDeps {
    inherit (final) pname version src;
    inherit hash;
  };

  nativeBuildInputs = [
    pnpm.configHook
    nodejs
    makeWrapper
    copyDesktopItems
  ];

  env.ELECTRON_SKIP_BINARY_DOWNLOAD = true;

  postConfigure = ''
    cp .env.example .env
  '';

  postBuild = ''
    pnpm build

    npm exec electron-builder -- \
        --dir \
        --config electron-builder.yml \
        -c.electronDist=${electron.dist} \
        -c.electronVersion=${electron.version}
  '';

  installPhase = ''
    runHook preInstall

    mkdir -p "$out/share/lib/splayer"
    cp -Pr --no-preserve=ownership dist/*-unpacked/{locales,resources{,.pak}} $out/share/lib/splayer

    _icon_sizes=(16x16 32x32 96x96 192x192 256x256 512x512)
    for _icons in "''${_icon_sizes[@]}";do
      install -Dm644 public/icons/favicon-$_icons.png $out/share/icons/hicolor/$_icons/apps/splayer.png
    done

    makeWrapper '${lib.getExe electron}' "$out/bin/splayer" \
      --add-flags $out/share/lib/splayer/resources/app.asar \
      --add-flags "\''${NIXOS_OZONE_WL:+\''${WAYLAND_DISPLAY:+--ozone-platform-hint=auto --enable-features=WaylandWindowDecorations --enable-wayland-ime=true}}" \
      --set-default ELECTRON_FORCE_IS_PACKAGED 1 \
      --set-default ELECTRON_IS_DEV 0 \
      --inherit-argv0

    runHook postInstall
  '';

  desktopItems = [
    (makeDesktopItem {
      name = "splayer";
      desktopName = "SPlayer";
      exec = "splayer %U";
      terminal = false;
      type = "Application";
      icon = "splayer";
      startupWMClass = "SPlayer";
      comment = "A minimalist music player";
      categories = [
        "AudioVideo"
        "Audio"
        "Music"
      ];
    })
  ];

  meta = {
    description = "Simple Netease cloud music client";
    homepage = "https://github.com/imsyy/SPlayer";
    license = lib.licenses.agpl3Only;
    mainProgram = "splayer";
    platforms = lib.platforms.linux;
  };
})
