{ stdenv, lib, fetchurl, python3, numactl }:

stdenv.mkDerivation rec {
  pname = "rt-tests";
  version = "2.2";

  src = fetchurl {
    url = "https://mirrors.edge.kernel.org/pub/linux/utils/rt-tests/rt-tests-${version}.tar.gz";
    sha256 = "sha256-eHoGfFDk4b3cKrLk48lkxSrf99qrtPZmHkXedLp2kTE=";
  };

  buildInputs = [ numactl python3 ];

  makeFlags = [ "prefix=$(out)" ];

  meta = with lib; {
    description = "test suite for real time Linux features";
    longDescription = ''
      rt-tests is a test suite, that contains programs to test various real time Linux features. It is maintained by Clark Williams and John Kacur. 
    '';
    homepage = https://wiki.linuxfoundation.org/realtime/documentation/howto/tools/rt-tests;
    license = licenses.gpl2Plus;
    platforms = numactl.meta.platforms;
    broken = true;
  };
}


