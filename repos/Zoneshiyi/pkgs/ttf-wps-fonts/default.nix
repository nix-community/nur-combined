{
  pkgs,
  lib,
  ...
}:
pkgs.stdenvNoCC.mkDerivation rec {
  pname = "ttf-wps-fonts";
  version = "1.0";

  src = pkgs.fetchFromGitHub {
    owner = "dv-anomaly";
    repo = "ttf-wps-fonts";
    rev = "8c980c24289cb08e03f72915970ce1bd6767e45a";
    hash = "sha256-x+grMnpEGLkrGVud0XXE8Wh6KT5DoqE6OHR+TS6TagI=";
  };

  phases = [
    "installPhase"
  ];

  installPhase = ''
    mkdir -p $out/share/fonts/truetype
    cp $src/*.ttf $out/share/fonts/truetype/
  '';

  meta = with lib; {
    description = "These are the symbol fonts required by wps-office. They are used to display math formulas. ";
    homepage = "https://github.com/dv-anomaly/ttf-wps-fonts";
    license = licenses.unfree;
    platforms = platforms.linux;
  };
}
