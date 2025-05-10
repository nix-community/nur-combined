{ config, lib, ... }:

let
  inherit (lib) mkEnableOption mkIf mkDefault;
  cfg = config.abszero.programs.hyprland;
in

{
  options.abszero.programs.hyprland.enable = mkEnableOption "Wayland compositor";

  # Most of the config is in home-manager
  config.programs = mkIf cfg.enable {
    hyprland = {
      enable = true;
      withUWSM = true;
    };
    hyprlock.enable = mkDefault true;
  };
}
