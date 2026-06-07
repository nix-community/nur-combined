{
  lib,
  buildNpmPackage,
  copyDesktopItems,
  electron,
  fetchFromGitHub,
  makeDesktopItem,
  makeBinaryWrapper,
}:

buildNpmPackage rec {
  pname = "apple-music-desktop";
  version = "2.2.0-unstable-20260306";

  src = fetchFromGitHub {
    owner = "Alex313031";
    repo = "apple-music-desktop";
    rev = "60be23ca85577765d02cfcbf7c668b3a20319981";
    hash = "sha256-SINvlS4br02G2s62jA7nsyNsBJhHHT6OOAOXCgE1/30=";
  };

  sourceRoot = "${src.name}/src";

  npmDepsHash = "sha256-N/nJcHajV06K9febJtuFBptl/x56066KnraR6lWISgQ=";
  forceGitDeps = true;
  makeCacheWritable = true;
  dontNpmBuild = true;

  env = {
    ELECTRON_SKIP_BINARY_DOWNLOAD = "1";
    npm_config_production = "true";
  };

  nativeBuildInputs = [
    copyDesktopItems
    makeBinaryWrapper
  ];

  postInstall = ''
    mkdir -p $out/share/icons/hicolor/256x256/apps
    install -Dm644 ${src}/Logo.png \
      $out/share/icons/hicolor/256x256/apps/apple-music-desktop.png

    makeWrapper ${lib.getExe electron} $out/bin/apple-music-desktop \
      --add-flags $out/lib/node_modules/${pname} \
      --add-flags "\''${NIXOS_OZONE_WL:+\''${WAYLAND_DISPLAY:+--ozone-platform-hint=auto --enable-features=WaylandWindowDecorations --enable-wayland-ime=true}}" \
      --set-default ELECTRON_IS_DEV 0 \
      --inherit-argv0
  '';

  desktopItems = [
    (makeDesktopItem {
      name = "apple-music-desktop";
      exec = "apple-music-desktop %U";
      icon = "apple-music-desktop";
      desktopName = "Apple Music Desktop";
      categories = [
        "Audio"
        "AudioVideo"
        "Player"
      ];
    })
  ];

  meta = {
    description = "Electron-based desktop client for Apple Music";
    homepage = "https://github.com/Alex313031/apple-music-desktop";
    license = lib.licenses.bsd3;
    mainProgram = "apple-music-desktop";
    platforms = lib.platforms.linux;
  };
}
