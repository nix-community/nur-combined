{
  config,
  pkgs,
  lib,
  ...
}:

let
  inherit (lib) mkEnableOption mkIf;
  cfg = config.abszero.themes.base.plymouth;
in

{
  options.abszero.themes.base.plymouth.rings_2 =
    mkEnableOption "rings_2 plymouth theme from plymouth-themes";

  config.boot.plymouth = mkIf cfg.rings_2 {
    enable = true;
    themePackages = with pkgs; [
      (adi1090x-plymouth-themes.override { selected_themes = [ "rings_2" ]; })
    ];
    theme = "rings_2";
  };
}
