{
  lib,
  stdenvNoCC,
  fetchItchIo,
  renpyMinimal,
  writableTmpDirAsHomeHook,
  unzip,
  makeWrapper,
  copyDesktopItems,
  makeDesktopItem,
}:
stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "oblivion2666demo";
  # Versions are not labled, so just the date.
  version = "1.0-2026-09-13";

  src = fetchItchIo {
    name = "oblivion2666demo-win-linux.zip";
    gameUrl = "https://solarautomata.itch.io/oblivion2666demo";
    upload = "19222206";
    hash = "sha256-QEcP2I4D6VieQkMshaeRN1KzK4uLH6a0IZj/wVF1cGI=";
  };

  strictDeps = true;
  __structuredAttrs = true;

  nativeBuildInputs = [
    unzip
    writableTmpDirAsHomeHook
    makeWrapper
    renpyMinimal
    copyDesktopItems
  ];

  buildPhase = ''
    runHook preBuild

    renpy . compile
    rm -r game/saves

    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall

    INSTALL_DIR="$out/share/oblivion2666demo"

    mkdir -p "$INSTALL_DIR"

    cp -r game "$INSTALL_DIR"

    find "$INSTALL_DIR" -type f -name "*.rpy" -delete

    makeWrapper ${lib.getExe renpyMinimal} "$out/bin/oblivion2666demo" \
      --add-flags "$INSTALL_DIR" --add-flags run

    runHook postInstall
  '';

  desktopItems = [
    (makeDesktopItem {
      name = "oblivion2666demo";
      desktopName = "Oblivion 2666 - Demo Disc";
      type = "Application";
      categories = [ "Game" ];
      exec = "oblivion2666demo";
    })
  ];

})
