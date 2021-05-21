{ stdenv, lib, fetchurl
# parameters are compiled in.
# Caution: the standard config uses 23GB of memory!
, params ? "-mavx -DSTREAM_ARRAY_SIZE=1000000000 -DNTIMES=20 -DVERBOSE" } :

stdenv.mkDerivation rec {
  pname = "stream-benchmark";
  version = "2013";

  src = fetchurl {
    url = "http://www.cs.virginia.edu/stream/FTP/Code/stream.c";
    sha256 = "0av966988yak2qcy4b3xgw8lgaxdhp0gjahi69w3zsjv2xgawax5";
  };

  dontUnpack = true;

  buildPhase = ''
    gcc -O3 -fopenmp -mcmodel=medium ${params} -lm "$src" -o stream
  '';

  installPhase = ''
    mkdir -p $out/bin
    install -m755 stream $out/bin
  '';

  meta = with lib; {
    description = "Measure memory transfer rates in MB/s for simple computational kernels";
    homepage = "http://www.cs.virginia.edu/stream/ref.html";
    license = licenses.bsd3;
    maintainers = [ maintainers.markuskowa ];
  };
}

