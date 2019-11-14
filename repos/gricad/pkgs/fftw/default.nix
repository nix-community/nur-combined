{stdenv,fetchurl, lib, precision ? "double", perl, cmake }:

with lib;

assert elem precision [ "single" "double" "long-double" "quad-precision" ];

let
  version = "3.3.8";
  withDoc = stdenv.cc.isGNU;
in

stdenv.mkDerivation rec {
  name = "fftw-${precision}-${version}";

  src = fetchurl {
    urls = [
      "http://fftw.org/fftw-${version}.tar.gz"
      "ftp://ftp.fftw.org/pub/fftw/fftw-${version}.tar.gz"
    ];
    sha256 = "00z3k8fq561wq2khssqg0kallk0504dzlx989x3vvicjdqpjc4v1";
  };
	nativeBuildInputs =[ cmake ];
  enableParallelBuilding = true;

  checkInputs = [ perl ];

  meta = with stdenv.lib; {
    description = "Fastest Fourier Transform in the West library";
    homepage = http://www.fftw.org/;
    license = licenses.gpl2Plus;
    maintainers = [ maintainers.spwhitt ];
    platforms = platforms.unix;
  };
}
