{ config, lib, pkgs, ... }:

with lib;
let
  cfg = config.hardware.regdomain;
  patch' = pkgs.runCommand "my-example" {} ''
    diff -urN zero ${pkgs.nur.repos.dukzcry.wireless-regdb}/net > $out
  '';
in {
  options.hardware.regdomain = {
    enable = mkEnableOption ''
      Bypass WiFi regulatory domain restrctions
    '';
  };
  config = mkIf cfg.enable {
    boot.kernelPatches = [ {
      name = "wireless-regdb";
      patch = ./{patch'};
    } ];
  };
}
