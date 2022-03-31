{ lib
, stdenv
, fetchFromGitLab
, pkg-config
, meson
, ninja
, wrapQtAppsHook
, qtbase
, wayland
}:

stdenv.mkDerivation rec {
  pname = "wlrootsqt";
  version = "unstable-2022-25-01";

  src = fetchFromGitLab {
    owner = "wlrootsqt";
    repo = "wlrootsqt";
    rev = "d86600bf9338fe5f6ff290711bf2b49373e55c1a";
    sha256 = "sha256-DDW+VaaGwB+TPwXr+yQT2kUgAIW/YhJ1uyUyFDkmn0g=";
  };

  nativeBuildInputs = [
    pkg-config
    meson
    ninja
    wrapQtAppsHook
  ];

  buildInputs = [
    qtbase
    wayland
  ];

  enableParallelBuilding = true;

  meta = with lib; {
    description = "The Qt-based library to handle Wayland and Wlroots protocols to be used with any Qt project";
    license = licenses.gpl3;
    platforms = platforms.linux;
    homepage = "https://gitlab.com/marcusbritanicus/QtGreet";
    maintainers = with maintainers; [ ilya-fedin ];
  };
}
