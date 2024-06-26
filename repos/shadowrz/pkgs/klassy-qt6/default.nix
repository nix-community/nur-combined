{
  lib,
  stdenv,
  fetchFromGitHub,
  cmake,
  extra-cmake-modules,
  kdecoration,
  kcoreaddons,
  kguiaddons,
  kconfigwidgets,
  kiconthemes,
  kwindowsystem,
  kwayland,
  kirigami,
  frameworkintegration,
  kcmutils,
  wrapQtAppsHook,
  qtsvg,
}:
stdenv.mkDerivation rec {
  pname = "klassy";
  version = "6.1.breeze6.0.3";

  src = fetchFromGitHub {
    owner = "paulmcauley";
    repo = pname;
    rev = version;
    sha256 = "sha256-D8vjc8LT+pn6Qzn9cSRL/TihrLZN4Y+M3YiNLPrrREc=";
  };

  cmakeFlags = ["-DBUILD_TESTING=OFF" "-DBUILD_QT5=OFF"];

  nativeBuildInputs = [cmake extra-cmake-modules wrapQtAppsHook];

  buildInputs = [
    kdecoration
    kcoreaddons
    kguiaddons
    kconfigwidgets
    kiconthemes
    kwayland
    kwindowsystem
    kirigami
    frameworkintegration
    kcmutils
    qtsvg
  ];

  meta = with lib; {
    description = "A highly customizable binary Window Decoration and Application Style plugin for recent versions of the KDE Plasma desktop";
    homepage = "https://github.com/paulmcauley/klassy";
    license = with licenses; [gpl2Only gpl2Plus gpl3Only bsd3 mit];
  };
}
