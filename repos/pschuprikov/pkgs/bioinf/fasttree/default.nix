{ stdenv, fetchurl }:
stdenv.mkDerivation rec {
  version = "2.1.11";
  name = "FastTree-${version}";
  src = fetchurl {
    url = "http://www.microbesonline.org/fasttree/${name}.c";
    sha256 = "sha256:03q5lbm27cdzvjwh4yd0pqq7s624in7hklqk57llndq70dasw9lh";
  };
  dontUnpack = true;

  buildPhase = ''
    $CC -DNO_SSE -O3 -finline-functions -funroll-loops -Wall -o FastTree $src -lm
  '';

  installPhase = ''
    mkdir -p $out/bin
    cp FastTree $out/bin/
  '';

  meta = with stdenv.lib; {
    description = "Inference of approximately-maximum-likelihood trees for large multiple sequence alignments";
    homepage = http://www.microbesonline.org/fasttree/;
    license = licenses.gpl2;
    platforms = platforms.unix;
  };
}
