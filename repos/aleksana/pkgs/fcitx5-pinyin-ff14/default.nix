{ lib
, stdenvNoCC
, fetchurl
}:

stdenvNoCC.mkDerivation {
  pname = "fcitx5-pinyin-ff14";
  version = "20231219";

  src = fetchurl {
    url = "https://github.com/heddxh/ff14-fcitx5/releases/download/2023.12.19/ff14.dict";
    hash = "sha256-pMAqNEIuyICQolFlVA4gousYDJNAXp3ttF9MOMsmzCo=";
  };

  dontUnpack = true;

  installPhase = ''
    install -Dm644 $src $out/share/fcitx5/pinyin/dictionaries/fcitx5-pinyin-ff14.dict
  '';

  meta = with lib; {
    description = "Converted from a QQ IME dictionary from the NGA forum post 'Fantasy Technology FF14 Chinese Input Method dictionary' (auto update)";
    homepage = "https://github.com/heddxh/ff14-fcitx5";
  };
}
