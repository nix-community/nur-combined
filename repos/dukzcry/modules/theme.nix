imports: { config, lib, pkgs, ... }:

with lib;
let
  cfg = config.programs.theme;
in {
  inherit imports;

  options.programs.theme = {
    enable = mkEnableOption "theming.";
  };

  config = mkIf cfg.enable {
    gtk = {
      enable = true;
      theme.name = "HighContrastInverse";
    };
    qt = {
      enable = true;
      style = "adwaita-highcontrastinverse";
    };
    environment.variables.QT_QPA_PLATFORMTHEME = "gtk3";
  };
}
