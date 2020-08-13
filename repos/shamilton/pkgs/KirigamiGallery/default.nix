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
  version = "20.07.90";

  src = fetchFromGitHub {
    owner = "KDE";
    repo = "kirigami-gallery";
    rev = "v${version}";
    sha256 = "1xm29g0anpmg3j3mnjfvwia7npgmvpnx04q3d5ixmf52ybslyvlb";
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
