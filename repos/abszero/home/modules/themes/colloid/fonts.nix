{
  config,
  pkgs,
  lib,
  ...
}:

let
  inherit (lib) mkIf;
  inherit (lib.abszero.modules) mkExternalEnableOption;
  cfg = config.abszero.themes.colloid.fonts;
in

{
  imports = [ ../../../../lib/modules/config/abszero.nix ];

  options.abszero.themes.colloid.fonts.enable =
    mkExternalEnableOption config "fonts to use with colloid theme";

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
