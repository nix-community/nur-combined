{ stdenv, fetchurl, requireFile, gfortran, fftw, protobuf, openblasCompat
, automake, autoconf, libtool, zlib, bzip2, libxml2, flex, bison
}:

let
  version = "20200218";

in stdenv.mkDerivation {
  pname = "qdng";
  inherit version;

  src = requireFile {
    name = "qdng-${version}.tar.xz";
    sha256 = "0gdh5mb6wl66qcdmhg5yiz5irs1s3sgwmd12fzhxyfkxzkr7fagz";
  };

  configureFlags = [ "--enable-openmp" "--with-blas=-lopenblas" ];

  enableParallelBuilding = true;

  preConfigure = ''
    ./genbs
  '';

  buildInputs = [ gfortran fftw protobuf openblasCompat
                  bzip2 zlib libxml2 flex bison ];
  nativeBuildInputs = [ automake autoconf libtool ];

  meta = {
    description = "Quantum dynamics program package";
    platforms = stdenv.lib.platforms.linux;
    maintainer = "markus.kowalewski@gmail.com";
  };

}
