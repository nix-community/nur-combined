{ stdenv
, sources
, ...
} @ args:

stdenv.mkDerivation rec {
  inherit (sources.rime-dict) pname version src;
  installPhase = ''
    mkdir -p $out/share/rime-data
    find ${src} -name "*.dict.yaml" -exec cp {} $out/share/rime-data/ \;
  '';
}
