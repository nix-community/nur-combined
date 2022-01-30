{ stdenv
, sources
, ...
} @ args:

stdenv.mkDerivation rec {
  inherit (sources.rime-moegirl) pname version src;
  dontUnpack = true;
  installPhase = ''
    mkdir -p $out/share/rime-data
    cp ${src} $out/share/rime-data/moegirl.dict.yaml
  '';
}
