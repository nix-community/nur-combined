{
  lib,
  stdenvNoCC,
  fetchMediaFire,
  fetchWebIcon,
  unzip,
  copyInstallHook,
  copyIcons,
  resizeIcons,
  renpyBuildHook,
  renpyPackHook,
  renpyUnpackHook,
  renpyWrapHook,
  makeDesktopItem,
  copyDesktopItems,
  deleteUselessFiles,
  shrinkAssets,
  desktopToDarwinBundle,
}:

stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "eternum";
  version = "0.9.5";

  src = fetchMediaFire {
    name = "Eternum-${finalAttrs.version}-pc.zip";
    fileId = "uwgw7k9rcqg9kvj";
    hash = "sha256-Qean+9c+GEL6akTD4xEjfpxPlOSmC21lEc5q6sfoH5Q=";
  };

  __structuredAttrs = true;
  strictDeps = true;

  icon = "game/gui/window_icon.png";

  nativeBuildInputs = [
    unzip
    renpyUnpackHook
    shrinkAssets
    renpyBuildHook
    copyInstallHook
    renpyWrapHook
    copyDesktopItems
    copyIcons
    resizeIcons
    renpyPackHook
    deleteUselessFiles
  ]
  ++ lib.optional stdenvNoCC.hostPlatform.isDarwin desktopToDarwinBundle;

  desktopItems = [
    (makeDesktopItem {
      name = "eternum";
      desktopName = "Eternum";
      comment = finalAttrs.meta.description;
      exec = "${finalAttrs.meta.mainProgram} %U";
      icon = "eternum";
      categories = [ "Game" ];
    })
  ];

  passthru.updateScript = ./update.sh;

  meta = {
    description = "Adult visual novel about a story happening in Kredon and involving a hyper-reality MMORPG";
    homepage = "https://caribdis.itch.io/eternum";
    downloadPage = "https://caribdis.itch.io/eternum";
    changelog = "https://caribdis.itch.io/eternum/devlog";
    license = lib.licenses.unfree;
    maintainers = with lib.maintainers; [ ulysseszhan ];
    platforms = lib.platforms.all;
    mainProgram = "Eternum";
  };
})
