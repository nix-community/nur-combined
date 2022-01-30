{ stdenv
, sources
, ...
} @ args:

stdenv.mkDerivation rec {
  inherit (sources.route-chain) pname version src;
  enableParallelBuilding = true;
  installPhase = ''
    make install PREFIX=$out
  '';
}
