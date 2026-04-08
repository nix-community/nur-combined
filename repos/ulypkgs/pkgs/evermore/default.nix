{
  lib,
  stdenvNoCC,
  fetchMediaFire,
  fetchWebIcon,
  unzip,
  copyInstallHook,
  copyIcons,
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
  pname = "evermore";
  version = "0.5.1";

  src = fetchMediaFire {
    name = "Evermore-${finalAttrs.version}-pc.zip";
    fileId = "bprajqjvkxd3wk6";
    hash = "sha256-Ff0yCbW8IHLsKX9oww3DgZA0/Kiki0hWDUuqnA5jCAg=";
  };

  icon = "icon_p.ico";

  nativeBuildInputs = [
    unzip
    renpyUnpackHook
    shrinkAssets
    copyInstallHook
    renpyWrapHook
    copyDesktopItems
    copyIcons
    renpyPackHook
    deleteUselessFiles
  ]
  ++ lib.optional stdenvNoCC.hostPlatform.isDarwin desktopToDarwinBundle;

  desktopItems = [
    (makeDesktopItem {
      name = "evermore";
      desktopName = "Evermore";
      comment = finalAttrs.meta.description;
      exec = "${finalAttrs.meta.mainProgram} %U";
      icon = "evermore";
      categories = [ "Game" ];
    })
  ];

  meta = {
    description = "Adult visual novel about magical abilities, secret societies, and ancient evils";
    homepage = "https://prometheusevn.itch.io/evermore";
    downloadPage = "https://prometheusevn.itch.io/evermore";
    changelog = "https://prometheusevn.itch.io/evermore/devlog";
    license = lib.licenses.unfree;
    maintainers = with lib.maintainers; [ ulysseszhan ];
    platforms = lib.platforms.all;
    mainProgram = "Evermore";
    sourceProvenance = with lib.sourceTypes; [ binaryBytecode ];
  };
})
