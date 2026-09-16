{
  lib,
  stdenvNoCC,
  fetchItchIo,
  renpyMinimal,
  writableTmpDirAsHomeHook,
  makeWrapper,
  copyDesktopItems,
  makeDesktopItem,
}:
stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "moon-illusion";
  version = "1.3.2";

  src = fetchItchIo {
    name = "MoonIllusion-${finalAttrs.version}-linux.tar.bz2";
    gameUrl = "https://uraalice.itch.io/moon-illusion";
    upload = "16902469";
    hash = "sha256-aw1Xsdi53Et4i4PlxnkY1kFSschzDaym4Fxu5ZgrjN8=";
  };

  strictDeps = true;
  __structuredAttrs = true;

  nativeBuildInputs = [
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

    INSTALL_DIR="$out/share/moon-illusion"

    mkdir -p "$INSTALL_DIR"

    cp -r game "$INSTALL_DIR"

    find "$INSTALL_DIR" -type f -name "*.rpy" -delete

    makeWrapper ${lib.getExe renpyMinimal} "$out/bin/moon-illusion" \
      --add-flags "$INSTALL_DIR" --add-flags run

    runHook postInstall
  '';

  desktopItems = [
    (makeDesktopItem {
      name = "moon-illusion";
      desktopName = "Moon Illusion";
      type = "Application";
      categories = [ "Game" ];
      exec = "moon-illusion";
    })
  ];

})
