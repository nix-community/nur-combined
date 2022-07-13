{ stdenv
, lib
, fetchurl
}:

stdenv.mkDerivation rec {

  pname = "voro";

  src = fetchGit {
    url = "https://github.com/chr1shr/voro";
    rev = "da34486b2b63d588449f5cdf50e05d3122dba5a3";
    sha256 = "1jdjwhhbzw0pd46iny0gi0945iad1flvk0wpymrs46l0303xaqnn";
  };

  buildPhase = "make CXX=c++";

  installPhase = "make install PREFIX=$out";

  meta = with lib; {
    description = "A three-dimensional Voronoi cell library in C++";
    homepage = "http://math.lbl.gov/voro++/";
    license = licenses.bsd3; # Lawrence Berkeley National Labs BSD 3-Clause variant
  };

}
