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
  pname = "two-kinds-of-people";
  version = "1.0";

  src = fetchItchIo {
    name = "tkop-${finalAttrs.version}-pc.zip";
    gameUrl = "https://lacunova.itch.io/tkop";
    upload = "18254531";
    hash = "sha256-y0to2H0kXzQsOjI97IYz8sOzJBa8KQlbvN6wh6l+PtA=";
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

    INSTALL_DIR="$out/share/two-kinds-of-people"

    mkdir -p "$INSTALL_DIR"

    cp -r game "$INSTALL_DIR"

    find "$INSTALL_DIR" -type f -name "*.rpy" -delete

    makeWrapper ${lib.getExe renpyMinimal} "$out/bin/two-kinds-of-people" \
      --add-flags "$INSTALL_DIR" --add-flags run

    runHook postInstall
  '';

  desktopItems = [
    (makeDesktopItem {
      name = "two-kinds-of-people";
      desktopName = "Two Kinds of People";
      type = "Application";
      categories = [ "Game" ];
      exec = "two-kinds-of-people";
    })
  ];

})
