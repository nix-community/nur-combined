{
  config,
  pkgs,
  lib,
  ...
}:

let
  inherit (lib) mkEnableOption mkIf;
  cfg = config.abszero.themes.noctalia.gtk;
in

{
  options.abszero.themes.noctalia.gtk.enable = mkEnableOption "noctalia gtk theme";

  config.gtk = mkIf cfg.enable {
    gtk4.extraCss = ''@import url("noctalia.css");'';
    gtk3.extraCss = ''@import url("noctalia.css");'';
    iconTheme = {
      name = "Papirus";
      package = pkgs.papirus-icon-theme;
    };
  };
}
