{ pkgs, stdenv, ... }:

stdenv.mkDerivation {
  pname = "huiwen-mincho";
  version = "1.001";
  src = ./.;

  installPhase = ''
    mkdir -p $out/share/fonts/opentype/
    cp -r *.otf $out/share/fonts/opentype/

  '';

  meta = with pkgs.lib; {
    description = "汇文明朝体";
    homepage = "https://zhuanlan.zhihu.com/p/12669052378";
    license = licenses.ofl; 
    platforms = platforms.all;
  };
}
