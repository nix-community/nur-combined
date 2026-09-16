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
  pname = "moonlight-duelists";
  version = "1.0.3";

  src = fetchItchIo {
    name = "MoonlightDuelists-${finalAttrs.version}-linux.tar.bz2";
    gameUrl = "https://kayinad.itch.io/moonlight-duelists";
    upload = "17011576";
    hash = "sha256-sYniHdVeWIVl7sUMHoPHX0Unp5EoOqXUz6SkrxdkDZQ=";
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

    INSTALL_DIR="$out/share/moonlight-duelists"

    mkdir -p "$INSTALL_DIR"

    cp -r game "$INSTALL_DIR"

    find "$INSTALL_DIR" -type f -name "*.rpy" -delete

    makeWrapper ${lib.getExe renpyMinimal} "$out/bin/moonlight-duelists" \
      --add-flags "$INSTALL_DIR" --add-flags run

    runHook postInstall
  '';

  desktopItems = [
    (makeDesktopItem {
      name = "moonlight-duelists";
      desktopName = "Moonlight Duelists";
      type = "Application";
      categories = [ "Game" ];
      exec = "moonlight-duelists";
    })
  ];

})
