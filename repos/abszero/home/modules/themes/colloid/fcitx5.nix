{ config, lib, ... }:

let
  inherit (lib) mkEnableOption mkIf;
  cfg = config.abszero.themes.colloid.fcitx5;
in

{
  options.abszero.themes.colloid.fcitx5.enable = mkEnableOption "colloid fcitx5 theme";

  config.xdg.configFile."fcitx5/conf/classicui.conf".text = mkIf cfg.enable ''
    Theme=plasma
    Vertical Candidate List=True
    Font="Noto Sans 13"
    MenuFont="Open Sans 13"
    TrayFont="Open Sans 13"
    TrayOutlineColor=#ffffff00
    TrayTextColor=#000000
    PreferTextIcon=True
  '';
}
