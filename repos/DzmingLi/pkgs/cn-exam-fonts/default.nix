{ pkgs, stdenvNoCC, fetchzip, ... }:

stdenvNoCC.mkDerivation {
  pname = "cn-exam-fonts";
  version = "1.0.0";
  src = fetchzip {
    url = "https://github.com/DzmingLi/nur-packages/releases/download/cn-exam-fonts-1.0.0/cn-exam-fonts-1.0.0.tar.gz";
    hash = "sha256-qGFct+yKb+DD/QkoRZnno7JirCBw0YZB/qHo3aOSGgY=";
  };

  installPhase = ''
    mkdir -p $out/share/fonts/truetype/
    cp -r *.ttf $out/share/fonts/truetype/
  '';

  meta = with pkgs.lib; {
    description = "中国教育部考试通常使用的字体：方正书宋和方正黑体";
    license = licenses.unfree;
    platforms = platforms.all;
  };
}
