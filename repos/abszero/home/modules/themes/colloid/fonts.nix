{
  config,
  pkgs,
  lib,
  ...
}:

let
  inherit (lib) mkEnableOption mkIf;
  cfg = config.abszero.themes.colloid.fonts;
in

{
  options.abszero.themes.colloid.fonts.enable = mkEnableOption "fonts to use with colloid theme";

  config = mkIf cfg.enable {
    fonts.fontconfig.enable = true;

    home.packages = with pkgs; [
      inconsolata
      iosevka-inconsolata
      nerd-fonts.symbols-only
      noto-fonts-cjk-sans
    ];

    gtk.font = {
      package = pkgs.open-sans;
      name = "Open Sans";
      size = 14;
    };
  };
}
