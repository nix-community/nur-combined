{ stdenv, fetchFromGitHub, pkgconfig, autoreconfHook, psm2 }:

stdenv.mkDerivation rec {
  name = "libfabric-${version}";
  version = "1.6.1";

  enableParallelBuilding = true;

  src = fetchFromGitHub {
    owner = "ofiwg";
    repo = "libfabric";
    rev = "v${version}";
    sha256 = "0fsx9fx7z5pr2w0jh2lg4fk6csmp5qrpp1lj6vi5axvdndycfznn";
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
