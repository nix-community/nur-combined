{ pkgs,fetchzip, stdenv, ... }:

stdenv.mkDerivation {
  pname = "genryumin-tc";
  version = "2.100";
  
  src = fetchzip{
    url = "https://github.com/ButTaiwan/genryu-font/releases/download/v2.100/GenRyuMin2TC-otf.zip";
    sha256 = "sha256-asNB5Bn93B1yspBaoMg538IbRbmit9HW3JMvY/UlUGY=";
    stripRoot=false;
  };

  installPhase = ''
    mkdir -p $out/share/fonts/opentype/
    cp -r *.otf $out/share/fonts/opentype/
  '';

  meta = with pkgs.lib; {
    description = "源流明体丹";
    homepage = "https://github.com/genryu-font";
    license = licenses.ofl; 
    platforms = platforms.all;
  };
}
