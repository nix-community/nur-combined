{
  lib,
  stdenvNoCC,
  fetchMega,
  fetchurl,
  unzip,
  copyInstallHook,
  copyIcons,
  renpyPackHook,
  renpyUnpackHook,
  renpy7WrapHook,
  makeDesktopItem,
  copyDesktopItems,
  deleteUselessFiles,
  shrinkAssets,
  desktopToDarwinBundle,
}:

stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "summertime-saga";
  version = "0.20.16";

  src = fetchMega {
    name = "SummertimeSaga-${lib.replaceStrings [ "." ] [ "-" ] finalAttrs.version}pc.zip";
    fileId = "!AGMU2IRJ!MviBjFfW95I34xotAmH11KXlMBstn3MFvGK204MxFnM";
    hash = "sha256-QXda+a74gNK8Ff94B/v5p3yBq8gozVuNJGcqS8JlFyQ=";
  };

  __structuredAttrs = true;
  strictDeps = true;

  icon = fetchurl {
    url = "https://summertimesaga.com/favicon.ico";
    hash = "sha256-yjYFVzTcMKbS151xsSTGaQMb5U8Vr+gGMvHnGDuhe60=";
  };

  nativeBuildInputs = [
    unzip
    renpyUnpackHook
    shrinkAssets
    copyInstallHook
    renpy7WrapHook
    copyDesktopItems
    copyIcons
    renpyPackHook
    deleteUselessFiles
  ]
  ++ lib.optional stdenvNoCC.hostPlatform.isDarwin desktopToDarwinBundle;

  dontShrinkPng = true; # most pngs are already optimized

  desktopItems = [
    (makeDesktopItem {
      name = "summertime-saga";
      desktopName = "Summertime Saga";
      comment = finalAttrs.meta.description;
      exec = "${finalAttrs.meta.mainProgram} %U";
      icon = "summertime-saga";
      categories = [ "Game" ];
    })
  ];

  passthru.updateScript = ./update.sh;

  meta = {
    description = "Adult orientated high quality dating sim game";
    homepage = "https://summertimesaga.com";
    downloadPage = "https://summertimesaga.com/download";
    changelog = "https://summertimesaga.com/news";
    license = lib.licenses.unfree;
    maintainers = with lib.maintainers; [ ulysseszhan ];
    platforms = lib.platforms.all;
    mainProgram = "SummertimeSaga";
    sourceProvenance = with lib.sourceTypes; [ binaryBytecode ];
  };
})
