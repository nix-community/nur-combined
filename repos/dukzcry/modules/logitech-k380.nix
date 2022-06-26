{ config, lib, pkgs, ... }:

with lib;
let
  cfg = config.hardware.logitech-k380;
in {
  options.hardware.logitech-k380 = {
    enable = mkEnableOption "function keys default on Logitech k380 bluetooth keyboard.";
  };

  config = mkIf cfg.enable {
    services.udev.packages = [ pkgs.nur.repos.dukzcry.k380-function-keys-conf ];
  };
}
