{ config, lib, ... }:

let
  inherit (lib) mkEnableOption mkIf singleton;
  cfg = config.abszero.programs.hyprlock;
in

{
  options.abszero.programs.hyprlock.enable = mkEnableOption "wayland screen locker";

  # https://wiki.hyprland.org/Hypr-Ecosystem/hyprlock
  config = mkIf cfg.enable {
    assertions = singleton {
      assertion = config.abszero.services.hypridle.enable;
      message = "hyprlock requires hypridle to be enabled";
    };
    programs.hyprlock = {
      enable = true;
      settings = {
        general = {
          grace = 60; # 1min
          ignore_empty_input = true;
        };
      };
    };
  };
}
