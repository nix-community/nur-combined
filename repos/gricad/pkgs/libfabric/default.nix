{ lib, stdenv, fetchFromGitHub, pkgconfig, autoreconfHook, psm2 }:

stdenv.mkDerivation rec {
  name = "libfabric-${version}";
  version = "1.13.1";

  enableParallelBuilding = true;

  src = fetchFromGitHub {
    owner = "ofiwg";
    repo = "libfabric";
    rev = "v${version}";
    sha256 = "1llx7m4x3zjwnn1478xax9823nlbmp23djym3bwbrbfr2lq90i6i";
  };

  buildInputs = [ pkgconfig autoreconfHook psm2 ];

  preConfigure = ''
    ./autogen.sh
  '';

  configureFlags = [ "--enable-psm2=${psm2}" ] ;

  meta = with lib; {
    homepage = http://libfabric.org/;
    description = "Open Fabric Interfaces";
    license = licenses.gpl2;
    platforms = platforms.linux;
    maintainers = [ maintainers.bzizou ];
  };
}
