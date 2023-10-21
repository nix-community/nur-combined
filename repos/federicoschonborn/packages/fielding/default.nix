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
  version = "unstable-2023-10-21";

  src = fetchFromGitLab {
    domain = "invent.kde.org";
    owner = "utilities";
    repo = "fielding";
    # Last Qt5/KF5 version.
    rev = "113403d81c922c0c5e2b2f7e1d2022424ae0690d";
    hash = "sha256-1h3xMFbfxE6QOmpe9VILnI9jJRNboY9EYj7qVOmGc4k=";
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
