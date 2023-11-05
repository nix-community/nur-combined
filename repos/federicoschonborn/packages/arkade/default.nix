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
  version = "unstable-2023-11-05";

  src = fetchFromGitLab {
    domain = "invent.kde.org";
    owner = "games";
    repo = "arkade";
    rev = "823318ea507c74a181b68d16310c09c3fdbbf8d6";
    hash = "sha256-0DSHVFDfLoPzsbY+GP2ZlETuF7fl7tmwkvt3z9FSImg=";
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
    mainProgram = "arkade";
    description = "Collection of Arcade games developed in Kirigami";
    homepage = "https://invent.kde.org/games/arkade";
    license = with lib.licenses; [ bsd2 gpl3Plus ];
    platforms = lib.platforms.linux;
    maintainers = with lib.maintainers; [ federicoschonborn ];
  };
}
