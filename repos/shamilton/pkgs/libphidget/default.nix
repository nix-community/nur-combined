{ lib
, stdenv
, fetchurl
, pkg-config
, libusb1
}:
stdenv.mkDerivation rec {
  pname = "libphidget";
  version = "0.8.3";

  src = fetchurl {
    url = "https://cdn.phidgets.com/downloads/phidget22/libraries/linux/libphidget22.tar.gz";
    sha256 = "sha256-w4rVaLmwyw7H0cz+HrjrzXwWtPHhEaGxB87t68kdSNg=";
  };

  nativeBuildInputs = [ pkg-config ];
  buildInputs = [ libusb1 ];

  meta = with lib; {
    description = "Ncurses spreadsheet program for the terminal";
    license = licenses.lgpl3Plus;
    homepage = "https://github.com/andmarti1424/sc-im";
    maintainers = [ "Scott Hamilton <sgn.hamilton+nixpkgs@protonmail.com>" ];
    platforms = platforms.linux;
  };
}
