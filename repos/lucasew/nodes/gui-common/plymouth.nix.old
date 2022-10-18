{pkgs, lib, ...}:
let
  theme = "circle_hud";
in {
  boot.plymouth = {
    enable = true;
    # theme = "breeze";
    # logo = pkgs.stdenv.mkDerivation {
    #   name = "out.png";
    #   dontUnpack = true;
    #   src = pkgs.fetchurl {
    #     url = "http://www.utfpr.edu.br/icones/cabecalho/logo-utfpr/@@images/efcf9caf-6d29-4c24-8266-0b7366ea3a40.png";
    #     sha256 = "1gk744rkiqqla7k7qqdjicfaccryyxqwim8iv3di21k2d0glazns";
    #   };
    #   nativeBuildInputs = with pkgs; [
    #     imagemagick
    #   ];
    #   installPhase = ''
    #     convert -resize 50% $src $out
    #   '';
    # };
    inherit theme;
    themePackages = [
      (pkgs.stdenv.mkDerivation {
        name = "plymouth-themes";
        src = pkgs.fetchFromGitHub {
          owner = "adi1090x";
          repo = "plymouth-themes";
          rev = "bf2f570bee8e84c5c20caac353cbe1d811a4745f";
          sha256 = "sha256-VNGvA8ujwjpC2rTVZKrXni2GjfiZk7AgAn4ZB4Baj2k=";
        };
        installPhase = ''
          mkdir $out/share/plymouth/themes -p
          chmod +w -R $out/share/plymouth
          for f in $src/pack_*/${theme}; do
            cp -r $f $out/share/plymouth/themes/
          done
          chmod +w $out -R
          find $out -type f | while read file; do
            sed -i 's;/usr/share/plymouth;/etc/plymouth;g' "$file"
          done
        '';
      })
    ];
  };
}
