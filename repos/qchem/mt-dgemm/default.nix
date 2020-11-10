{ stdenv, fetchurl, openblasCompat } :

stdenv.mkDerivation {
  pname = "mt-dgeem";
  version = "20160114";

  src = fetchurl {
    url = "https://portal.nersc.gov/project/m888/apex/mt-dgemm_160114.tgz";
    sha256 = "04bcjw3if1fms321rpy3mxsnli0xmj5czz71xxamxa71j4yy30k3";
  };

  buildInputs = [ openblasCompat ];

  preBuild = ''
    makeFlagsArray+=("LIBS=-lopenblas")
    makeFlagsArray+=("CFLAGS=-DUSE_CBLAS")
  '';


  installPhase = ''
    mkdir -p $out/bin

    cp mt-dgemm $out/bin
  '';

  meta = with stdenv.lib; {
    description = "Simple matrix multiplication performance test";
    platforms = platforms.all;
    homepage = "https://portal.nersc.gov/project/m888/apex/";
    maintainers = [ maintainers.markuskowa ];
  };
}

