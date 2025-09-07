{
  lib,
  stdenvNoCC,
  fetchurl,
  nix-update-script,
  ...
}:
let
  pname = "fcitx5-pinyin-zhwiki";
  version = "0.2.5";
  date = "20250310";
in
stdenvNoCC.mkDerivation {
  inherit pname version;

  src = fetchurl {
    url = "https://github.com/felixonmars/fcitx5-pinyin-zhwiki/releases/download/${version}/zhwiki-${date}.dict";
    sha256 = "073a8kr83lb9yb3krrsbhmhrf23g78nvby2yqi1mjbf2fwna2z7g";
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
