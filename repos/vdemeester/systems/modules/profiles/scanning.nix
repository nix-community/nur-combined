{ config, lib, pkgs, ... }:

with lib;
let
  cfg = config.profiles.scanning;
in
{
  options = {
    profiles.scanning = {
      enable = mkOption {
        default = false;
        description = "Enable scanning profile";
        type = types.bool;
      };
    };
  };
  config = mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      saneFrontends
      saneBackends
      simple-scan
    ];
    hardware.sane = {
      enable = true;
      extraConfig = { "pixma" = "bjnp://192.168.12.70"; };
    };
  };
}
