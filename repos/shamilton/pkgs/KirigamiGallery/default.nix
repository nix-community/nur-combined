{ lib
, mkDerivation
, fetchFromGitHub
, cmake
, extra-cmake-modules
, qtbase
, qtquickcontrols2
, kitemmodels
, kactivities
}:

mkDerivation rec {
  pname = "KirigamiGallery";
  version = "21.04.0";

  src = fetchFromGitHub {
    owner = "KDE";
    repo = "kirigami-gallery";
    rev = "v${version}";
    sha256 = "084af9xbz86h0cdk6q2aywx99xc85pz6f8zmn3sw065050syr3iy";
  };

  nativeBuildInputs = [ extra-cmake-modules cmake  ];
  buildInputs = [ qtquickcontrols2 kactivities qtbase ];
  propagatedBuildInputs = [ kitemmodels ];

  meta = with lib; {
    description = "View examples of Kirigami components";
    license = licenses.lgpl2;
    homepage = "https://kde.org/applications/en/development/org.kde.kirigami2.gallery";
    maintainers = [ "Scott Hamilton <sgn.hamilton+nixpkgs@protonmail.com>" ];
    platforms = platforms.linux;
  };
}
