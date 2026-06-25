{ pkgs, stdenvNoCC, fetchurl, ... }:

stdenvNoCC.mkDerivation {
  pname = "KingHwaOldSong";
  version = "3.0";
  src = fetchurl {
    url = "https://github.com/DzmingLi/nur-packages/releases/download/KingHwaOldSong-3.0/KingHwaOldSong-3.0.ttf";
    hash = "sha256-9/75/EE+niND8LtDLFHMpBxEuP438HHchrBQiWrp+eI=";
  };

  dontUnpack = true;

  installPhase = ''
    install -Dm644 $src $out/share/fonts/truetype/KingHwaOldSong-3.0.ttf
  '';

  meta = with pkgs.lib; {
    description = "京华老宋体";
    homepage = "https://zhuanlan.zhihu.com/p/1915922891633043436";
    license = licenses.ofl;
    platforms = platforms.all;
  };
}
