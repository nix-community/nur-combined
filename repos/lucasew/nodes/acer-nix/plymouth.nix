{pkgs, ...}: {
  boot.plymouth = {
    enable = true;
    theme = "breeze";
    logo = pkgs.stdenv.mkDerivation {
      name = "out.png";
      dontUnpack = true;
      src = pkgs.fetchurl {
        url = "http://www.utfpr.edu.br/icones/cabecalho/logo-utfpr/@@images/efcf9caf-6d29-4c24-8266-0b7366ea3a40.png";
        sha256 = "1gk744rkiqqla7k7qqdjicfaccryyxqwim8iv3di21k2d0glazns";
      };
      nativeBuildInputs = with pkgs; [
        imagemagick
      ];
      installPhase = ''
        convert -resize 50% $src $out
      '';
    };
  };
}
