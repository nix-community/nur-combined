{ lib
, stdenv
, fetchFromGitLab
, cmake
, extra-cmake-modules
, qtbase
, qtquickcontrols2
, wrapQtAppsHook
, kdbusaddons
, kitemmodels
, kirigami2
, kirigami-addons
, kcoreaddons
, kconfig
, ki18n
, unstableGitUpdater
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
    wrapQtAppsHook
  ];

  buildInputs = [
    qtbase
    qtquickcontrols2
    kdbusaddons
    kitemmodels
    kirigami2
    kirigami-addons
    kcoreaddons
    kconfig
    ki18n
  ];

  passthru = {
    updateScript = unstableGitUpdater { };
  };

  meta = with lib; {
    description = "Choose a license for your project";
    homepage = "https://invent.kde.org/sdk/licentia";
    license = with licenses; [
      bsd2
      cc-by-30
      cc0
      gpl3Plus
      lgpl2Plus
      lgpl21Plus
    ];
    platforms = platforms.linux;
    maintainers = with maintainers; [ federicoschonborn ];
  };
}
