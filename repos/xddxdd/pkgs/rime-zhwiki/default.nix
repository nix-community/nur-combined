{ stdenv
, sources
, ...
} @ args:

stdenv.mkDerivation rec {
  inherit (sources.rime-zhwiki) pname version src;
  dontUnpack = true;
  installPhase = ''
    mkdir -p $out/share/rime-data
    cp ${src} $out/share/rime-data/zhwiki.dict.yaml
  '';
}
