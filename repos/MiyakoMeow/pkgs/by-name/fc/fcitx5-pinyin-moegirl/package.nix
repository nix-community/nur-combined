{
  lib,
  stdenvNoCC,
  fetchurl,
  ...
}:
let
  pname = "fcitx5-pinyin-moegirl";
  date = "20250309";
in
stdenvNoCC.mkDerivation {
  inherit pname;
  version = date;

  src = fetchurl {
    url = "https://github.com/outloudvi/mw2fcitx/releases/download/${date}/moegirl.dict";
    sha256 = "1y75pf3a1p0l4pqx6hdcv0rqd42ai0ciibldfjvp5icsjwzfb5fi";
  };

  dontUnpack = true;

  installPhase = ''
    install -Dm644 $src $out/share/fcitx5/pinyin/dictionaries/fcitx5-pinyin-moegirl.dict
  '';

  meta = with lib; {
    description = "Fcitx 5 pinyin dictionary generator for MediaWiki instances. Releases for dict of zh.moegirl.org.cn. (auto update)";
    homepage = "https://github.com/outloudvi/mw2fcitx";
    license = licenses.mit;
  };
}
