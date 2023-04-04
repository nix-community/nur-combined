{ lib
, mkDerivation
, fetchFromGitHub
, cmake
, extra-cmake-modules
, kdecoration
, qtx11extras
, kcoreaddons
, kguiaddons
, kconfigwidgets
, kiconthemes
, kwindowsystem
, kwayland
, kirigami2
, frameworkintegration
, kcmutils
}:

mkDerivation rec {
  pname = "klassy";
  version = "4.0.breeze5.25.80";

  src = fetchFromGitHub {
    owner = "paulmcauley";
    repo = pname;
    rev = version;
    sha256 = "sha256-GYwGLI5UP3slISrlZsawCz58AIfbtbNvQ5KluOae/w8=";
  };

  extraCmakeFlags = [ "-DBUILD_TESTING=OFF" ];

  nativeBuildInputs = [ cmake extra-cmake-modules ];

  buildInputs = [
    kdecoration
    qtx11extras
    kcoreaddons
    kguiaddons
    kconfigwidgets
    kiconthemes
    kwayland
    kwindowsystem
    kirigami2
    frameworkintegration
    kcmutils
  ];

  meta = with lib; {
    description = "A highly customizable binary Window Decoration and Application Style plugin for recent versions of the KDE Plasma desktop";
    homepage = "https://github.com/paulmcauley/klassy";
    license = with licenses; [ gpl2Only gpl2Plus gpl3Only bsd3 mit ];
  };
}
