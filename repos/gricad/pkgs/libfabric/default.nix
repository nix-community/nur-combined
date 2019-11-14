{ stdenv, fetchFromGitHub, pkgconfig, autoreconfHook, psm2 }:

stdenv.mkDerivation rec {
  name = "libfabric-${version}";
  version = "1.8.1";

  enableParallelBuilding = true;

  src = fetchFromGitHub {
    owner = "ofiwg";
    repo = "libfabric";
    rev = "v${version}";
    sha256 = "1qf4jz9bkq6f6dpcg5d5r0yjbqizaqxqakpwbgcr08jg4s3pp6la";
  };

  buildInputs = [ pkgconfig autoreconfHook psm2 ];

  preConfigure = ''
    ./autogen.sh
  '';

  configureFlags = [ "--enable-psm2=${psm2}/usr" ] ;

  meta = with stdenv.lib; {
    homepage = http://libfabric.org/;
    description = "Open Fabric Interfaces";
    license = stdenv.lib.licenses.gpl2;
    platforms = platforms.linux;
    maintainers = [ maintainers.bzizou ];
  };
}
