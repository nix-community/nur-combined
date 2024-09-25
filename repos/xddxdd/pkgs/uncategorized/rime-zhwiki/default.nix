{
  stdenvNoCC,
  sources,
  lib,
  ...
}:
stdenvNoCC.mkDerivation rec {
  inherit (sources.rime-zhwiki) pname version src;
  dontUnpack = true;
  installPhase = ''
    runHook preInstall

    mkdir -p $out/share/rime-data
    cp $src $out/share/rime-data/zhwiki.dict.yaml

    runHook postInstall
  '';

  meta = with lib; {
    maintainers = with lib.maintainers; [ xddxdd ];
    description = "Fcitx 5 Pinyin Dictionary from zh.wikipedia.org";
    homepage = "https://github.com/felixonmars/fcitx5-pinyin-zhwiki";
    license = licenses.unlicense;
  };
}
