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
  version = "2.2.0-unstable-20250505";

  src = fetchFromGitHub {
    owner = "Alex313031";
    repo = "apple-music-desktop";
    rev = "bd4dd2f44690ca8ed206f08070e25f02f989dfe5";
    hash = "sha256-tzEKg2/41vLK2m47Z4ySCaAeg1HvwT2OgvhhVWswmXE=";
  };

  sourceRoot = "${src.name}/src";

  npmDepsHash = "sha256-2xkaB+LdDfdSlGZ5NR7SBRhW3t7QbEFKB6NB5yDoh2Y=";
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
