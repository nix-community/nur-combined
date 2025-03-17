{
  lib,
  stdenv,
  fetchurl,
}:

stdenv.mkDerivation rec {
  pname = "fasttree";
  version = "2.1";

  src = fetchurl {
    url = "http://www.microbesonline.org/fasttree/FastTree.c";
    hash = "sha256-kCauVQMHN0vpKRPTCY+NRBh9ML6geQK53L+xI+qiBQ8=";
  };

  meta = with lib; {
    description = "";
    homepage = "";
    license = licenses.gpl2Plus;
    maintainers = with maintainers; [ dschrempf ];
  };

  unpackPhase = ''
    mkdir source
    cp ${src} source/FastTree.c
    cd source
  '';

  buildPhase = ''
    gcc -Wall -O3 -finline-functions -funroll-loops -o FastTree -lm FastTree.c
  '';

  installPhase = ''
    mkdir -p $out/bin
    cp FastTree $out/bin/FastTree
    cd $out/bin
    ln -s FastTree fasttree
  '';
}
