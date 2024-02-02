{ lib
, stdenvNoCC
, fetchurl
}:

stdenvNoCC.mkDerivation {
  pname = "fcitx5-pinyin-moegirl";
  version = "20231114";

  src = fetchurl {
    url = "https://github.com/outloudvi/mw2fcitx/releases/download/20231114/moegirl.dict";
    hash = "sha256-x+XkATiNMNbcSiN87MkRRvKiNuzvpmkDrtGkwdnIsYM=";
  };

  dontUnpack = true;

  installPhase = ''
    install -Dm644 $src $out/share/fcitx5/pinyin/dictionaries/fcitx5-pinyin-moegirl.dict
  '';

  meta = with lib; {
    description = " Fcitx 5 pinyin dictionary generator for MediaWiki instances. Releases for dict of zh.moegirl.org.cn. (auto update)";
    homepage = "https://github.com/outloudvi/mw2fcitx";
    license = licenses.unlicense;
  };
}
