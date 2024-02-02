{ lib
, stdenvNoCC
, fetchurl
}:

stdenvNoCC.mkDerivation {
  pname = "fcitx5-pinyin-zhwiki";
  version = "20231205";

  src = fetchurl {
    url = "https://github.com/felixonmars/fcitx5-pinyin-zhwiki/releases/download/0.2.4/zhwiki-20231205.dict";
    hash = "sha256-crMmSqQ7QgmjgEG8QpvBgQYfvttCUsKYo8gHZGXIZmc=";
  };

  dontUnpack = true;

  installPhase = ''
    install -Dm644 $src $out/share/fcitx5/pinyin/dictionaries/fcitx5-pinyin-zhwiki.dict
  '';

  meta = with lib; {
    description = "Fcitx 5 Pinyin Dictionary from zh.wikipedia.org (auto update)";
    homepage = "https://github.com/felixonmars/fcitx5-pinyin-zhwiki";
    license = licenses.unlicense;
  };
}
