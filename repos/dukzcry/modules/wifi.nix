{ config, lib, pkgs, ... }:

with lib;
let
  cfg = config.hardware.wifi;
in {
  options.hardware.wifi = {
    enable = mkEnableOption ''
      Wifi hacks
    '';
  };
}
