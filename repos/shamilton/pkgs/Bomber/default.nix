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

  pname = "Bomber";
  version = "19.12.3";

  src = fetchurl {
    url = "mirror://kde/stable/release-service/19.12.3/src/bomber-19.12.3.tar.xz";
    sha256 = "ea4926fe08c62ac5da28c3bb480a6986e51f7a77e3245d1dc1603c38617da4b0";
    name = "bomber-19.12.3.tar.xz";
  };

  nativeBuildInputs = [ extra-cmake-modules cmake  ];

  buildInputs = [ libkdegames kactivities qtbase ];

  meta = with lib; {
    description = "Arcade Bombing Game";
    license = licenses.gpl2;
    homepage = "https://kde.org/applications/en/games/org.kde.bomber";
    maintainers = [ "Scott Hamilton <sgn.hamilton+nixpkgs@protonmail.com>" ];
    platforms = platforms.linux;
  };
}
