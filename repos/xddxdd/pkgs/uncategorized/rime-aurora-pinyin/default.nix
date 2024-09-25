{
  sources,
  stdenvNoCC,
  lib,
  ...
}:
stdenvNoCC.mkDerivation {
  inherit (sources.rime-aurora-pinyin) pname version src;
  installPhase = ''
    runHook preInstall

    mkdir -p $out/share/rime-data
    cp *.yaml $out/share/rime-data/

    runHook postInstall
  '';

  meta = with lib; {
    maintainers = with lib.maintainers; [ xddxdd ];
    description = "【极光拼音】输入方案";
    homepage = "https://github.com/hosxy/rime-aurora-pinyin";
    license = licenses.asl20;
  };
}
