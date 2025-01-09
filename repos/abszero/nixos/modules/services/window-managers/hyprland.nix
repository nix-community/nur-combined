# NOTE: The hyprland option in NixOS is `programs.hyprland`, however we use
#       `wayland.windowManager.hyprland` to be consistent with home-manager.
{ config, lib, ... }:

let
  inherit (lib) mkEnableOption mkIf mkDefault;
  cfg = config.abszero.wayland.windowManager.hyprland;
in

{
  options.abszero.wayland.windowManager.hyprland.enable = mkEnableOption "Wayland compositor";

  # Most of the config is in home-manager
  config.programs = mkIf cfg.enable {
    hyprland = {
      enable = true;
      withUWSM = true;
    };
    hyprlock.enable = mkDefault true;
  };
}
