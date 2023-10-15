{ lib
, stdenv
, fetchFromGitLab
, cmake
, extra-cmake-modules
, ninja
, wrapQtAppsHook
, kconfig
, kcoreaddons
, kdbusaddons
, ki18n
, kirigami2
, qtbase
, qtquickcontrols2
}:

stdenv.mkDerivation {
  pname = "fielding";
  version = "unstable-2023-07-28";

  src = fetchFromGitLab {
    domain = "invent.kde.org";
    owner = "utilities";
    repo = "fielding";
    rev = "e0b669fde40183aa0445899a4bfbfeb9ce138f45";
    hash = "sha256-C/jz7L/SlbMCOXRr3FDOFOE1v3RuO+zohmNX/iuOp2s=";
  };

  nativeBuildInputs = [
    cmake
    extra-cmake-modules
    ninja
    wrapQtAppsHook
  ];

  buildInputs = [
    kconfig
    kcoreaddons
    kdbusaddons
    ki18n
    kirigami2
    qtbase
    qtquickcontrols2
  ];

  meta = {
    description = "A simple REST API testing tool";
    homepage = "https://invent.kde.org/utilities/fielding";
    license = with lib.licenses; [
      bsd2
      cc0
      gpl3Plus
      lgpl2Plus
      lgpl21Plus
    ];
    platforms = lib.platforms.linux;
    maintainers = with lib.maintainers; [ federicoschonborn ];
  };
}
