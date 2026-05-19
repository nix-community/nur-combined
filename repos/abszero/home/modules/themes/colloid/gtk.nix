{
  config,
  pkgs,
  lib,
  ...
}:

let
  inherit (lib) mkEnableOption mkIf;
  cfg = config.abszero.themes.colloid.gtk;
in

{
  options.abszero.themes.colloid.gtk.enable = mkEnableOption "colloid gtk theme";

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
