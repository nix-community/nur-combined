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
mkDerivation {

  pname = "spectacle-clipboard";
  version = "unstable";

  src = fetchFromGitHub {
    owner = "SCOTT-HAMILTON";
    repo = "spectacle";
    rev = "678004f9fab0d678c72b5b0269e4bd0d82ef45f7";
    sha256 = "0xs5jbj9f13lacni5i506b4w138bvf3d6cy6h1wa2z8jzmb5nx5c";
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
    description = "KDE Spectacle fork to enable clipboard funcionnalities";
    license = licenses.mit;
    homepage = "https://github.com/SCOTT-HAMILTON/spectacle";
    maintainers = [ "Scott Hamilton <sgn.hamilton+nixpkgs@protonmail.com>" ];
    platforms = platforms.linux;
  };
}
