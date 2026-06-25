{ pkgs, stdenvNoCC, fetchurl, ... }:

stdenvNoCC.mkDerivation {
  pname = "Huiwen-mincho";
  version = "1.001";
  src = fetchurl {
    url = "https://github.com/DzmingLi/nur-packages/releases/download/Huiwen-mincho-1.001/huiwen-mincho.otf";
    hash = "sha256-HqXQRQwNA0w+QHfytTPXT70b8fFNk4R3OJM45k09jZw=";
  };

  dontUnpack = true;

  installPhase = ''
    install -Dm644 $src $out/share/fonts/opentype/huiwen-mincho.otf
  '';

  meta = with pkgs.lib; {
    description = "汇文明朝体";
    homepage = "https://zhuanlan.zhihu.com/p/12669052378";
    license = licenses.ofl;
    platforms = platforms.all;
  };
}
