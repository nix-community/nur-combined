{ lib
, stdenv
, fetchFromGitLab
, cmake
, extra-cmake-modules
, ninja
, wrapQtAppsHook
, ki18n
, kirigami2
, kpackage
, qtbase
, qtquickcontrols2
, unstableGitUpdater
}:

stdenv.mkDerivation {
  pname = "arkade";
  version = "unstable-2023-09-23";

  src = fetchFromGitLab {
    domain = "invent.kde.org";
    owner = "games";
    repo = "arkade";
    rev = "8acb6572e4d9dd4483f2a792ff19f2b00abce5e8";
    hash = "sha256-MK4IDntze471MEGDxRXWv1+nKUNEnatMJRAJCmqJF00=";
  };

  nativeBuildInputs = [
    cmake
    extra-cmake-modules
    ninja
    wrapQtAppsHook
  ];

  buildInputs = [
    ki18n
    kirigami2
    kpackage
    qtbase
    qtquickcontrols2
  ];

  passthru.updateScript = unstableGitUpdater { };

  meta = {
    description = "Collection of Arcade games developed in Kirigami";
    homepage = "https://invent.kde.org/games/arkade";
    license = with lib.licenses; [ bsd2 gpl3Plus ];
    platforms = lib.platforms.linux;
    maintainers = with lib.maintainers; [ federicoschonborn ];
  };
}
