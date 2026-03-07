{
  lib,
  stdenv,
  fetchFromGitHub,
  copyDesktopItems,
  desktopToDarwinBundle,
  makeDesktopItem,
  qt5,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "qiec104";
  version = "1.1.1";

  src = fetchFromGitHub {
    owner = "MicroKoder";
    repo = "QIEC104";
    tag = "v${finalAttrs.version}";
    hash = "sha256-/kIAWxeJATKSEqXfRA3/6+TbHVeaIWZqsMYumvj2OuU=";
  };

  nativeBuildInputs = [
    copyDesktopItems
    qt5.qmake
    qt5.wrapQtAppsHook
  ]
  ++ lib.optional stdenv.isDarwin desktopToDarwinBundle;

  desktopItems = [
    (makeDesktopItem {
      name = "qiec104";
      desktopName = "Q104";
      comment = finalAttrs.meta.description;
      exec = "Q104";
      icon = "Q104";
      terminal = false;
      categories = [
        "Utility"
      ];
    })
  ];

  postInstall = ''
    install -Dm755 Q104 -t $out/bin
    install -Dm644 icons/Q104.png -t $out/share/icons/hicolor/128x128/apps
  '';

  meta = {
    description = "Small IEC104 client";
    homepage = "https://github.com/MicroKoder/QIEC104";
    license = lib.licenses.mit;
    maintainers = [ lib.maintainers.sikmir ];
    platforms = lib.platforms.unix;
  };
})
