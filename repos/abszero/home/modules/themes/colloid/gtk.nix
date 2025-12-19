{
  config,
  pkgs,
  lib,
  ...
}:

let
  inherit (lib) mkIf;
  inherit (lib.abszero.modules) mkExternalEnableOption;
  cfg = config.abszero.themes.colloid.gtk;
in

{
  imports = [ ../../../../lib/modules/config/abszero.nix ];

  options.abszero.themes.colloid.gtk.enable = mkExternalEnableOption config "colloid gtk theme";

  config.gtk = mkIf cfg.enable {
    theme = {
      package = pkgs.colloid-gtk-theme_git;
      name = "Colloid-Light";
    };
    iconTheme = {
      package = pkgs.colloid-icon-theme;
      name = "Colloid";
    };
  };
}
