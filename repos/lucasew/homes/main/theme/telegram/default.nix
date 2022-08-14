{ pkgs, ... }:
let
  inherit (pkgs.custom) colors colorpipe;
  inherit (colors.colors) base00 base01 base02 base03 base04 base05 base06 base07 base08 base09 base0A base0B base0C base0D base0E base0F;
in {
  home.file."Downloads/theme.tdesktop-theme" = {
    source = pkgs.stdenv.mkDerivation {
      # borrowed from https://gitlab.com/theova/base16-telegram-desktop/-/blob/master/templates/default.mustache
      name = "base16.tdesktop-theme";
      nativeBuildInputs = with pkgs; [
        imagemagick
        zip
        colorpipe
      ];
      dontUnpack = true;
      buildPhase = ''
        cat ${./template.txt} | colorpipe > colors.tdesktop-theme
        convert -size 1x1 xc:"#${base00}" background.png
      '';
      installPhase = ''
        zip "$out" colors.tdesktop-theme background.png
      '';
    };
  };
}
