{
  lib,
  stdenvNoCC,
  fetchItchIo,
  fetchWebIcon,
  makeDesktopItem,
  copyInstallHook,
  copyDesktopItems,
  resizeIcons,
  godot43WrapHook,
  unzip,
  godotpcktool,
  desktopToDarwinBundle,
}:

stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "oppai-oppai-orbs";
  version = "0-unstable-2025-08-19";

  src = fetchItchIo {
    name = "orbs-windows.zip";
    gameUrl = finalAttrs.meta.homepage;
    upload = "8980925";
    hash = "sha256-85p2FB620iVhp+U7V/wq/zxVAZsBQb+rqGvlW1rR0PU=";
  };

  __structuredAttrs = true;
  strictDeps = true;

  nativeBuildInputs = [
    unzip
    copyInstallHook
    godot43WrapHook
    copyDesktopItems
    resizeIcons
    godotpcktool
  ]
  ++ lib.optional stdenvNoCC.hostPlatform.isDarwin desktopToDarwinBundle;

  preInstall = ''
    godotpcktool --pack *.pck --action extract --include-regex-filter 'icon\.png'
    install -Dm644 *.png $out/share/icons/hicolor/256x256/apps/oppai-oppai-orbs.png
    rm icon.*
  '';

  desktopItems = [
    (makeDesktopItem {
      name = "oppai-oppai-orbs";
      desktopName = "Oppai Oppai Orbs";
      comment = finalAttrs.meta.description;
      exec = "${finalAttrs.meta.mainProgram} %U";
      icon = "oppai-oppai-orbs";
      categories = [ "Game" ];
    })
  ];

  meta = {
    description = "Fruit game but with girl that breast expands to the size of the biggest two orbs in playfield";
    homepage = "https://inksgirls.itch.io/orbs";
    downloadPage = "https://inksgirls.itch.io/orbs";
    changelog = "https://inksgirls.itch.io/orbs/devlog";
    license = lib.licenses.unfree;
    mainProgram = "oppai-oppai-orbs";
    maintainers = with lib.maintainers; [ ulysseszhan ];
    sourceProvenance = with lib.sourceTypes; [ binaryBytecode ];
  };
})
