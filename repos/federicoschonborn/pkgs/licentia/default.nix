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
}:

stdenv.mkDerivation {
  pname = "licentia";
  version = "unstable-2023-08-02";

  src = fetchFromGitLab {
    domain = "invent.kde.org";
    owner = "sdk";
    repo = "licentia";
    rev = "189fcc53051536b0150cfb0a177aa1b4021afac7";
    hash = "sha256-qeGnusTngzDr7YGa58Duwu9pGpCqfLzaeQJIYoTqXPI=";
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

  meta = {
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
