{ lib, stdenv, fetchFromGitHub, sconsPackages, libusb1, pkg-config }:

stdenv.mkDerivation {
  pname = "xfer9860";
  version = "unstable-2019-01-28";

  src = fetchFromGitHub {
    owner = "sanjay900";
    repo = "xfer9860";
    rev = "b869779e5ac43ba6fcb549020ccf84f686813ebc";
    sha256 = "19wybkvv5rxi5hi831gx7zdfd4d9bkqwb2f1hn1d3czycrk80kk0";
  };

  nativeBuildInputs = [ pkg-config ];
  buildInputs = [ libusb1 ];

  buildPhase = ''
    mkdir -p $out/bin
    gcc src/*.c -o $out/bin/xfer9860 $(pkg-config --cflags --libs libusb-1.0)
  '';

  installPhase = "true";

  meta = with lib; {
    broken = false;
    homepage = "https://github.com/sanjay900/xfer9860";
    description = "open source equivalent of FA-124 by Casio";
    license = licenses.gpl2Only;
    platforms = platforms.linux;
  };
}
