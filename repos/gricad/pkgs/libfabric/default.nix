{ stdenv, fetchFromGitHub, pkgconfig, autoreconfHook, psm2 }:

stdenv.mkDerivation rec {
  name = "libfabric-${version}";
  version = "1.9.0";

  enableParallelBuilding = true;

  src = fetchFromGitHub {
    owner = "ofiwg";
    repo = "libfabric";
    rev = "v${version}";
    sha256 = "07mnscjhhbvp2nwl36rxprxkvkcms108kd7k75r2psm9nap2hlr1";
  };

  buildInputs = [ pkgconfig autoreconfHook psm2 ];

  preConfigure = ''
    ./autogen.sh
  '';

  configureFlags = [ "--enable-psm2=${psm2}" ] ;

  meta = with stdenv.lib; {
    homepage = http://libfabric.org/;
    description = "Open Fabric Interfaces";
    license = stdenv.lib.licenses.gpl2;
    platforms = platforms.linux;
    maintainers = [ maintainers.bzizou ];
  };
}
