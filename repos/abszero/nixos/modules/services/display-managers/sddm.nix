{
  config,
  pkgs,
  lib,
  ...
}:

let
  inherit (lib) mkEnableOption mkIf mkDefault;
  cfg = config.abszero.services.displayManager.sddm;
in

{
  options.abszero.services.displayManager.sddm.enable = mkEnableOption "sddm as the display manager";

  config.services.displayManager.sddm = mkIf cfg.enable {
    enable = true;
    # Use Qt6 SDDM
    package = mkDefault pkgs.kdePackages.sddm;
    wayland.enable = true;
  };
}
