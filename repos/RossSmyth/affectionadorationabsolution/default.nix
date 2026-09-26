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
  pname = "affectionadorationabsolution";
  version = "1.0";

  src = fetchItchIo {
    name = "affectionadorationabsolution-0.1-pc.zip";
    gameUrl = "https://mismatched-wings.itch.io/affectionadorationabsolution";
    upload = "15247939";
    hash = "sha256-wskb7BgeayQn0H4T5Jei5zAmGsoSjpD1x/jd2IVxc5M=";
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

    INSTALL_DIR="$out/share/affectionadorationabsolution"

    mkdir -p "$INSTALL_DIR"

    cp -r game "$INSTALL_DIR"

    find "$INSTALL_DIR" -type f -name "*.rpy" -delete

    makeWrapper ${lib.getExe renpyMinimal} "$out/bin/affectionadorationabsolution" \
      --add-flags "$INSTALL_DIR" --add-flags run

    runHook postInstall
  '';

  desktopItems = [
    (makeDesktopItem {
      name = "affectionadorationabsolution";
      desktopName = "Affection/Adoration/Absolution";
      type = "Application";
      categories = [ "Game" ];
      exec = "affectionadorationabsolution";
    })
  ];

})
