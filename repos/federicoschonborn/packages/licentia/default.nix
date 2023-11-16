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
, kitemmodels
, qtbase
, qtquickcontrols2
, unstableGitUpdater
}:

stdenv.mkDerivation {
  pname = "licentia";
  version = "unstable-2023-11-07";

  src = fetchFromGitLab {
    domain = "invent.kde.org";
    owner = "sdk";
    repo = "licentia";
    rev = "958e3586fff044b26218a0e47bb05f2d9a237759";
    hash = "sha256-c/W3WdOyUCbtBDaP1lROKHDAIFrj4TiDypIpIBQHa98=";
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
    kitemmodels
    qtbase
    qtquickcontrols2
  ];

  passthru.updateScript = unstableGitUpdater { };

  meta = {
    mainProgram = "licentia";
    description = "Choose a license for your project";
    homepage = "https://invent.kde.org/sdk/licentia";
    license = with lib.licenses; [
      bsd2
      cc-by-30
      cc0
      gpl3Plus
      lgpl2Plus
      lgpl21Plus
    ];
    platforms = lib.platforms.linux;
    maintainers = with lib.maintainers; [ federicoschonborn ];
    broken = lib.versionOlder kirigami-addons.version "0.9";
  };
}
