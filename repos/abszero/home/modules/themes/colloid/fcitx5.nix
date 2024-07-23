{ config, lib, ... }:

let
  inherit (lib) mkIf;
  inherit (lib.abszero.modules) mkExternalEnableOption;
  cfg = config.abszero.themes.colloid.fcitx5;
in

{
  imports = [ ../../../../lib/modules/config/abszero.nix ];

  options.abszero.themes.colloid.fcitx5.enable = mkExternalEnableOption config "colloid fcitx5 theme";

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
