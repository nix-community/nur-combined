{ stdenv, fetchurl
, pkgconfig, desktop-file-utils
, SDL, gtk3
}:

# Builds but can't find files at runtime because of hardcoded paths
stdenv.mkDerivation rec {
  name = "sfxr-${version}";
  version = "1.2.1";
  src = fetchurl {
    url = "http://www.drpetter.se/files/sfxr-sdl-${version}.tar.gz";
    sha256 = "0dfqgid6wzzyyhc0ha94prxax59wx79hqr25r6if6by9cj4vx4ya";
  };
  postPatch = ''
    substituteInPlace Makefile --replace "usr/" ""
  '';
  nativeBuildInputs = [ pkgconfig desktop-file-utils ];
  buildInputs = [ SDL gtk3 ];
  makeFlags = [ "DESTDIR=$(out)" ];
}

