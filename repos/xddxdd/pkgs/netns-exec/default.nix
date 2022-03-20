{ stdenv
, sources
, ...
} @ args:

stdenv.mkDerivation rec {
  inherit (sources.netns-exec) pname version src;
  buildPhase = ''
    substituteInPlace Makefile --replace "-m4755" "-m755"
  '';
  installPhase = ''
    mkdir -p $out
    make install PREFIX=$out
  '';
}
