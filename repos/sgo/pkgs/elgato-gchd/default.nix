{ stdenv, fetchFromGitHub, fetchurl, lib, cmake, pkgconfig, libusb, elgato-gchd-firmware }:

stdenv.mkDerivation rec {
  pname = "elgato-gchd";
  version = "unstable-2016-12-23";


  src = fetchFromGitHub {
    owner = "tolga9009";
    repo  = "elgato-gchd";
    rev   = "e5bc6b98b4da4c6328a06eadf9458c0a944af043";
    sha256 = "0w9pk2ghaszia4z06lp9hjzmdwrjmj87v7cnxsamykg9zn8fxd4f";
  };

  nativeBuildInputs = [ cmake pkgconfig ];
  buildInputs = [ libusb ];
  propagatedBuildInputs = [ elgato-gchd-firmware ];

}
