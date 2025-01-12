{ lib, stdenv

, fetchFromGitHub

, copyDesktopItems
, makeDesktopItem

, cmake
, pkg-config

, SDL2
, curl
}:
stdenv.mkDerivation (finalAttrs: {
  pname = "lampray";
  version = "1.3.2";

  src = fetchFromGitHub {
    owner = "CHollingworth";
    repo = "Lampray";
    tag = "v${finalAttrs.version}";
    hash = "sha256-q6XoGbP1PvNY/0j7EhIHE3nY/iwmxyb/JkgNEp90PZU=";
  };

  nativeBuildInputs = [
    cmake
    pkg-config
    copyDesktopItems
  ];

  buildInputs = [
    SDL2
    curl.dev
  ];

  hardeningDisable = [ "format" ];

  postInstall = ''
    mkdir -p $out/bin
    cp Lampray $out/bin/lampray
  '';

  desktopItems = [
    (makeDesktopItem {
      name = "lampray";

      desktopName = "Lampray";
      comment = "Baldur's Gate 3 and Cyberpunk mod manager for Linux";
      exec = "lampray";
      icon = "station";
      terminal = false;
      categories = [ "Game" ];
    })
  ];

  meta = {
    description = "Linux Application Modding Platform. A native Linux mod manager";
    homepage = "https://github.com/CHollingworth/Lampray";
    changelog = "https://github.com/CHollingworth/Lampray/blob/${finalAttrs.src.tag}/CHANGELOG.md";
    license = lib.licenses.unlicense;
    mainProgram = "lampray";
    platforms = lib.platforms.all;
  };
})
