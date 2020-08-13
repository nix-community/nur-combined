{ lib
, mkDerivation
, fetchurl
, cmake
, extra-cmake-modules
, qtbase
, kactivities
}:
mkDerivation {

  pname = "KAppTemplate";
  version = "19.12.3";

  src = fetchurl {
    url = "mirror://kde/stable/release-service/19.12.3/src/kapptemplate-19.12.3.tar.xz";
    sha256 = "5bef4e4fb74da3102cba6672584195962514ee3f53fb369b48d492d6ce7255ad";
    name = "kapptemplate-19.12.3.tar.xz";
  };

  nativeBuildInputs = [ extra-cmake-modules cmake  ];

  buildInputs = [ kactivities qtbase ];

  meta = with lib; {
    description = "KDE App Code Template Generator";
    license = licenses.gpl2;
    homepage = "https://kde.org/applications/en/development/org.kde.kapptemplate";
    maintainers = [ "Scott Hamilton <sgn.hamilton+nixpkgs@protonmail.com>" ];
    platforms = platforms.linux;
  };
}
