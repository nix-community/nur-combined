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
  pname = "once-in-a-lifetime";
  version = "1.0.0";

  src = fetchMediaFire {
    name = "Onceinalifetime-${finalAttrs.version}-pc.zip";
    fileId = "qkosfzge7ii4bn4";
    hash = "sha256-HUnp56TCHGd7p25xqkNXI+nMlN9rjKJVUHP6jwWUF+w=";
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
      name = "once-in-a-lifetime";
      desktopName = "Once in a Lifetime";
      comment = finalAttrs.meta.description;
      exec = "${finalAttrs.meta.mainProgram} %U";
      icon = "once-in-a-lifetime";
      categories = [ "Game" ];
    })
  ];

  meta = {
    description = "Choice-based visual novel made in Ren'py with tons of romance, mystery, humor, and much more";
    homepage = "https://caribdis.itch.io/once-in-a-lifetime";
    downloadPage = "https://caribdis.itch.io/once-in-a-lifetime";
    changelog = "https://caribdis.itch.io/once-in-a-lifetime/devlog";
    license = lib.licenses.unfree;
    maintainers = with lib.maintainers; [ ulysseszhan ];
    platforms = lib.platforms.all;
    mainProgram = "Onceinalifetime";
  };
})
