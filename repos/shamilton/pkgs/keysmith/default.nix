{ lib
, mkDerivation
, makeWrapper
, fetchFromGitHub
, cmake
, extra-cmake-modules
, qtbase
, qtquickcontrols2
, qtdeclarative
, qtgraphicaleffects
, kirigami2
, oathToolkit
, ki18n
, libsodium
, kdbusaddons
, kwindowsystem
}:

mkDerivation rec {
  pname = "keysmith";
  version = "23.04.0";

  src = fetchFromGitHub {
    owner = "KDE";
    repo = "keysmith";
    rev = "v${version}";
    sha256 = "sha256-NE1dpxupUVOEOOVQKwKeltqjfFR3j7EbMIC16C7+9wc=";
  };

  nativeBuildInputs = [ cmake extra-cmake-modules makeWrapper ];
  buildInputs = [
    libsodium
    ki18n
    kirigami2
    qtquickcontrols2
    qtbase
    kdbusaddons
    kwindowsystem
  ];

  meta = with lib; {
    description = "OTP client for Plasma Mobile and Desktop";
    license = licenses.gpl3;
    homepage = "https://github.com/KDE/keysmith";
    maintainers = [ "Scott Hamilton <sgn.hamilton+nixpkgs@protonmail.com>" ];
    platforms = platforms.linux;
  };
}
