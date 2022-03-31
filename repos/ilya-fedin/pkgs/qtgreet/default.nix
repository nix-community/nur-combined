{ lib
, stdenv
, fetchFromGitLab
, pkg-config
, meson
, ninja
, wrapQtAppsHook
, qtbase
, wlrootsqt
, json_c
}:

stdenv.mkDerivation rec {
  pname = "qtgreet";
  version = "unstable-2022-25-01";

  src = fetchFromGitLab {
    owner = "marcusbritanicus";
    repo = "QtGreet";
    rev = "311c1c89f3914e84dcabcc6e382c4eb63301b435";
    sha256 = "sha256-LyCds0TptruOUaN9H3wSbq0fRYWNCteSKoPg6ny2Yg8=";
  };

  patches = [
    ./paths.patch
    ./xsession.patch
  ];

  nativeBuildInputs = [
    pkg-config
    meson
    ninja
    wrapQtAppsHook
  ];

  buildInputs = [
    qtbase
    wlrootsqt
    json_c
  ];

  enableParallelBuilding = true;

  meta = with lib; {
    description = "Qt based greeter for greetd, to be run under wayfire or similar wlr-based compositors";
    license = licenses.gpl3;
    platforms = platforms.linux;
    homepage = "https://gitlab.com/marcusbritanicus/QtGreet";
    maintainers = with maintainers; [ ilya-fedin ];
  };
}
