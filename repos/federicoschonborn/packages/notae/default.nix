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
, kirigami-addons
, kirigami2
, qtbase
, qtquickcontrols2
, syntax-highlighting
, unstableGitUpdater
}:

stdenv.mkDerivation {
  pname = "notae";
  version = "unstable-2023-08-11";

  src = fetchFromGitLab {
    domain = "invent.kde.org";
    owner = "utilities";
    repo = "notae";
    rev = "511474ec6e8ccdee079d91720d1b6602861e121d";
    hash = "sha256-y4YjISMRBRSgHeX8RfXR8La29lPZAR6b9OD7kzmBMuU=";
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
    kirigami-addons
    kirigami2
    qtbase
    qtquickcontrols2
    syntax-highlighting
  ];

  passthru.updateScript = unstableGitUpdater { };

  meta = {
    mainProgram = "notae";
    description = "A simple note taking application that automatically saves your work";
    homepage = "https://invent.kde.org/utilities/notae";
    license = with lib.licenses; [
      bsd2
      bsd3
      cc0
      gpl3Plus
      lgpl2Plus
      lgpl21Plus
    ];
    platforms = lib.platforms.linux;
    maintainers = with lib.maintainers; [ federicoschonborn ];
  };
}
