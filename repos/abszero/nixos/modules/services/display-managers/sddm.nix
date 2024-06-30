{ config, lib, ... }:

let
  inherit (lib) mkEnableOption mkIf;
  cfg = config.abszero.services.displayManager.sddm;
in

{
  options.abszero.services.displayManager.sddm.enable = mkEnableOption "sddm as the display manager";

  config.services.displayManager.sddm = mkIf cfg.enable {
    enable = true;
    wayland.enable = true;
  };
}
