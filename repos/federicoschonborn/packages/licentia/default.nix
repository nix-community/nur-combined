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
  version = "unstable-2023-10-14";

  src = fetchFromGitLab {
    domain = "invent.kde.org";
    owner = "sdk";
    repo = "licentia";
    rev = "23499d671adf39494a35cfa084086503b47adf4c";
    hash = "sha256-Ix7UNmloZw9u8NOXdU01xV/dhNmjGNFEyS61HoXssQY=";
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
