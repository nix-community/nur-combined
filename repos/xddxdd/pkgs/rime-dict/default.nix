{ stdenvNoCC
, sources
, lib
, ...
} @ args:

stdenvNoCC.mkDerivation rec {
  inherit (sources.rime-dict) pname version src;
  installPhase = ''
    mkdir -p $out/share/rime-data
    find ${src} -name "*.dict.yaml" -exec cp {} $out/share/rime-data/ \;
  '';

  meta = with lib; {
    description = "RIME 词库增强";
    homepage = "https://github.com/Iorest/rime-dict";
  };
}
