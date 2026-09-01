{
  fetchurl,
  stdenv,
  lib,
}:
stdenv.mkDerivation (finalAttrs: {
  pname = "rime-zhwiki";
  version = "20240509";
  src = fetchurl {
    url = "https://github.com/felixonmars/fcitx5-pinyin-zhwiki/releases/download/0.2.5/zhwiki-${finalAttrs.version}.dict.yaml";
    hash = "sha256-lihR5q+brhaweHD1ggtAzvFMqQ2Rt+REeOH4K8V20gI=";
  };
  dontUnpack = true;
  installPhase = ''
    runHook preInstall

    mkdir -p $out/share/rime-data
    cp $src $out/share/rime-data/zhwiki.dict.yaml

    runHook postInstall
  '';

  passthru.updateScript = [ (toString ./update.sh) ];
  meta = {
    maintainers = with lib.maintainers; [ xddxdd ];
    description = "RIME dictionary file for entries from zh.wikipedia.org";
    homepage = "https://github.com/felixonmars/fcitx5-pinyin-zhwiki";
    license = [
      lib.licenses.fdl13Plus
      lib.licenses.cc-by-sa-40
    ];
  };
})
