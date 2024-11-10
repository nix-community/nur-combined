{
  stdenvNoCC,
  sources,
  lib,
}:
stdenvNoCC.mkDerivation {
  inherit (sources.rime-zhwiki) pname version src;

  dontUnpack = true;
  installPhase = ''
    runHook preInstall

    mkdir -p $out/share/rime-data
    cp $src $out/share/rime-data/zhwiki.dict.yaml

    runHook postInstall
  '';

  meta = {
    maintainers = with lib.maintainers; [ xddxdd ];
    description = "RIME dictionary file for entries from zh.wikipedia.org";
    homepage = "https://github.com/felixonmars/fcitx5-pinyin-zhwiki";
    license = [
      lib.licenses.fdl13Plus
      lib.licenses.cc-by-sa-40
    ];
  };
}
