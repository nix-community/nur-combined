{
  lib,
  stdenvNoCC,
  fetchItchIo,
  fetchWebIcon,
  makeDesktopItem,
  copyInstallHook,
  copyDesktopItems,
  copyIcons,
  godot3WrapHook,
  genericUnpackHook,
}:

stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "legbreaker";
  version = "1.1";

  src = fetchItchIo {
    name = "Legbreaker_Lin.zip";
    gameUrl = finalAttrs.meta.homepage;
    upload = "2567058";
    hash = "sha256-Y4WWBFjHO2DnoesfKEzWnvGQo1aeW5GVSfPWdUsgX5Q=";
  };

  icon = fetchWebIcon {
    url = finalAttrs.meta.homepage;
    hash = "sha256-k8xbE+LUvJYRfPq6vQ+10QdmWRqJCewO4qxQ4Yu5fUQ=";
  };

  nativeBuildInputs = [
    genericUnpackHook
    copyInstallHook
    godot3WrapHook
    copyDesktopItems
    copyIcons
  ];

  desktopItems = [
    (makeDesktopItem {
      name = "legbreaker";
      desktopName = "Legbreaker";
      comment = finalAttrs.meta.description;
      exec = "${finalAttrs.meta.mainProgram} %U";
      icon = "legbreaker";
      categories = [ "Game" ];
    })
  ];

  meta = {
    description = "Puzzle platformer where you can only jump twice";
    homepage = "https://almbkn.itch.io/legbreaker";
    downloadPage = "https://almbkn.itch.io/legbreaker";
    license = lib.licenses.unfree;
    mainProgram = "Legbreaker";
    maintainers = with lib.maintainers; [ ulysseszhan ];
    sourceProvenance = with lib.sourceTypes; [ binaryBytecode ];
  };
})
