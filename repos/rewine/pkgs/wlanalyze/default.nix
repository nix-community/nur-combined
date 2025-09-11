{
  lib,
  stdenv,
  fetchFromGitHub,
  cmake,
  qt6Packages,
}:

stdenv.mkDerivation rec {
  pname = "wlanalyze";
  version = "0-unstable-2025-08-12";

  src = fetchFromGitHub {
    owner = "rgriebl";
    repo = "wlanalyze";
    rev = "8b6f0aaeab02495c5200c1f338caf48fad1acfde";
    hash = "sha256-gjMMwe3exbYdLRv7XU8VuB0TM31GHiI/UmUUIwCvH6g=";
  };

  nativeBuildInputs = [
    cmake
    qt6Packages.wrapQtAppsHook
  ];

  buildInputs = [
    qt6Packages.qtbase
  ];

  meta = {
    description = "Qt UI to analyze WAYLAND_DEBUG output";
    homepage = "https://github.com/rgriebl/wlanalyze.git";
    license = lib.licenses.gpl3Only;
    maintainers = with lib.maintainers; [ wineee ];
    mainProgram = "wlanalyze";
    platforms = lib.platforms.all;
  };
}
