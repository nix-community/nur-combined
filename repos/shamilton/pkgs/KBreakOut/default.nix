{ lib
, mkDerivation
, fetchurl
, cmake
, extra-cmake-modules
, qtbase
, kactivities
, libkdegames
}:
mkDerivation {

  pname = "KBreakOut";
  version = "19.12.3";

  src = fetchurl {
    url = "mirror://kde/stable/release-service/19.12.3/src/kbreakout-19.12.3.tar.xz";
    sha256 = "ca662c9f2c6765f5f8b07bd4cc2e2aa0a43b69fec6428c3deda2cfad0ab675fa";
    name = "kbreakout-19.12.3.tar.xz";
  };

  nativeBuildInputs = [ extra-cmake-modules cmake  ];

  buildInputs = [ libkdegames kactivities qtbase ];

  meta = with lib; {
    description = "KDE's Breakout-like Game";
    license = licenses.gpl2;
    homepage = "https://kde.org/applications/en/games/org.kde.kbreakout";
    maintainers = [ "Scott Hamilton <sgn.hamilton+nixpkgs@protonmail.com>" ];
    platforms = platforms.linux;
  };
}
