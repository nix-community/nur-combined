{ config, lib, pkgs, ... }:

with lib;
let
  cfg = config.hardware.regdomain;
in {
  options.hardware.regdomain = {
    enable = mkEnableOption ''
      Bypass WiFi regulatory domain restrctions
    '';
  };
}
