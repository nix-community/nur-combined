{ lib, pkgs, config, ... }:
with lib;
let
  cfg = config.dotfiles.fonts;
in {
  options.dotfiles.fonts = {
    enable = mkEnableOption "Install fonts";
  };

  config = mkIf cfg.enable {
    fonts.fontconfig.enable = true;

    home.packages = with pkgs; [
      noto-fonts
      source-han-sans
      source-han-mono
      source-han-serif
      source-han-code-jp 
      meslo-lgs-nf
    ];
  };
}
