{ lib
, mkDerivation
, fetchFromGitHub
, cmake
, extra-cmake-modules
, qtbase
, qttools
, kcoreaddons
, kwidgetsaddons
, kdbusaddons
, knotifications
, ki18n
, kio
, knewstuff
, kwayland
, libkipi
, kpurpose
, libpthreadstubs
, libXdmcp
, xcb-util-cursor
, qtx11extras
}:
mkDerivation rec {

  pname = "spectacle-clipboard";
  version = "master";

  src = fetchFromGitHub {
    owner = "SCOTT-HAMILTON";
    repo = "spectacle";
    rev = "349b33c4a82ddb69724a8e085c364bac2d5a04ff";
    sha256 = "1xylvhs2fni0vjkqp2p92hbby9151ydk54gmh6l3rdlvbp7i1sx8";
  };

  postPatch = ''
    substituteInPlace desktop/org.kde.spectacle.desktop.cmake \
      --replace "Exec=@QtBinariesDir@/qdbus" "Exec=${lib.getBin qttools}/bin/qdbus"
  '';

  nativeBuildInputs = [ xcb-util-cursor libXdmcp qtbase cmake ];
  buildInputs = [ qtx11extras libpthreadstubs kpurpose libkipi kwayland knewstuff kio ki18n knotifications 
  kdbusaddons kwidgetsaddons 
  kcoreaddons extra-cmake-modules qtbase qttools ];

  meta = with lib; {
    description = "The new screenshot capture utility, replaces KSnapshot";
    license = licenses.mit;
    homepage = "https://github.com/SCOTT-HAMILTON/spectacle";
    maintainers = [ "Scott Hamilton <sgn.hamilton+nur@protonmail.com>" ];
    platforms = platforms.linux;
  };
}
