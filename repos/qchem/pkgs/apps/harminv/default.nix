{ lib, stdenv, fetchurl, autoreconfHook, gfortran, blas, lapack } :

stdenv.mkDerivation rec {
  pname = "harminv";
  version = "1.4.1";

  src = fetchurl {
    url = "https://github.com/NanoComp/${pname}/releases/download/v${version}/${pname}-${version}.tar.gz";
    sha256 = "0w1n4d249vlpda0hi6z1v13qp21vlbp3ykn0m8qg4rd5132j7fg1";
  };

  nativeBuildInputs = [ gfortran ];

  buildInputs = [ blas lapack ];

  configureFlags = [ "--enable-shared" ];

  meta = with lib; {
    description = "Harmonic inversion algorithm of Mandelshtam: decompose signal into sum of decaying sinusoids";
    homepage = "https://github.com/NanoComp/harminv";
    license = with licenses; [ gpl2Only ];
    maintainers = [ maintainers.sheepforce ];
    platforms = platforms.linux;
  };
}
