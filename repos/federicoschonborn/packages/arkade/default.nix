{ lib
, stdenv
, fetchFromGitLab
, cmake
, extra-cmake-modules
, ninja
, wrapQtAppsHook
, kirigami2
, kpackage
, qtquickcontrols2
, unstableGitUpdater
}:

stdenv.mkDerivation {
  pname = "arkade";
  version = "unstable-2023-12-08";

  src = fetchFromGitLab {
    domain = "invent.kde.org";
    owner = "games";
    repo = "arkade";
    rev = "a36de247ee91e920bb8a67cc3df2673f285878cd";
    hash = "sha256-rYUZFLgeApiCx4eglCdvb442CB9hLhVjhrdJCMTmRcw=";
  };

  nativeBuildInputs = [
    cmake
    extra-cmake-modules
    ninja
    wrapQtAppsHook
  ];

  buildInputs = [
    kirigami2
    kpackage
    qtquickcontrols2
  ];

  passthru.updateScript = unstableGitUpdater { };

  meta = {
    mainProgram = "arkade";
    description = "Collection of Arcade games developed in Kirigami";
    homepage = "https://invent.kde.org/games/arkade";
    license = with lib.licenses; [ bsd2 gpl3Plus ];
    maintainers = with lib.maintainers; [ federicoschonborn ];
  };
}
