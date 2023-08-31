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
  config = mkIf cfg.enable {
    boot.kernelPatches = [ {
      name = "wireless-regdb";
      patch = null;
      extraConfig = ''
        EXPERT y
        CFG80211_CERTIFICATION_ONUS y
        CFG80211_EXTRA_REGDB_KEYDIR ${pkgs.nur.repos.dukzcry.wireless-regdb}/lib/crda/pubkeys
      '';
    } ];
  };
}
