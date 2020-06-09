{ lib
, mkDerivation
, fetchFromGitHub
, cmake
, extra-cmake-modules
, qtbase
, qtquickcontrols2
, kactivities
}:
mkDerivation rec {

  pname = "KirigamiGallery";
  version = "20.04.1";

  src = fetchFromGitHub {
    owner = "KDE";
    repo = "kirigami-gallery";
    rev = "v${version}";
    sha256 = "00kq82l538kamyfvxxwzbvxma69yz4xa56v5a9g3xdww2ff9qipj";
  };

  nativeBuildInputs = [ extra-cmake-modules cmake  ];

  buildInputs = [ qtquickcontrols2 kactivities qtbase ];

  meta = with lib; {
    description = "View examples of Kirigami components";
    license = licenses.lgpl2;
    homepage = "https://kde.org/applications/en/development/org.kde.kirigami2.gallery";
    maintainers = [ "Scott Hamilton <sgn.hamilton+nixpkgs@protonmail.com>" ];
    platforms = platforms.linux;
  };
}
