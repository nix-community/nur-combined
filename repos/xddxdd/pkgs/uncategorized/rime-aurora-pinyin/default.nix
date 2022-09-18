{ sources
, stdenvNoCC
, lib
, fetchurl
, ...
}:

stdenvNoCC.mkDerivation {
  inherit (sources.rime-aurora-pinyin) pname version src;
  installPhase = ''
    mkdir -p $out/share/rime-data
    cp *.yaml $out/share/rime-data/
  '';

  meta = with lib; {
    description = "【极光拼音】输入方案";
    homepage = "https://github.com/hosxy/rime-aurora-pinyin";
    license = licenses.asl20;
  };
}
