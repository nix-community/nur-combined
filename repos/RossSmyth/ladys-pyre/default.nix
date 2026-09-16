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
  pname = "ladys-pyre";
  version = "1.0";

  src = fetchItchIo {
    name = "aladyspyre-pc.zip";
    gameUrl = "https://uraalice.itch.io/ladys-pyre";
    upload = "18310082";
    hash = "sha256-y2bRZfgwoBlx5jN/QeZC4L6ZVaqHt7XTb/bXk4NKH3c=";
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

    INSTALL_DIR="$out/share/ladys-pyre"

    mkdir -p "$INSTALL_DIR"

    cp -r game "$INSTALL_DIR"

    find "$INSTALL_DIR" -type f -name "*.rpy" -delete

    makeWrapper ${lib.getExe renpyMinimal} "$out/bin/ladys-pyre" \
      --add-flags "$INSTALL_DIR" --add-flags run

    runHook postInstall
  '';

  desktopItems = [
    (makeDesktopItem {
      name = "ladys-pyre";
      desktopName = "A Lady's Pyre";
      type = "Application";
      categories = [ "Game" ];
      exec = "ladys-pyre";
    })
  ];

})
