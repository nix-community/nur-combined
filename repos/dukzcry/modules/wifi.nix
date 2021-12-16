{ config, lib, pkgs, ... }:

with lib;
let
  cfg = config.hardware.wifi;
  crda = (pkgs.crda.override {
    inherit (pkgs.nur.repos.dukzcry) wireless-regdb;
  }).overrideAttrs (oldAttrs: rec {
    makeFlags = oldAttrs.makeFlags ++ [
      "PUBKEY_DIR=${pkgs.nur.repos.dukzcry.wireless-regdb}/lib/crda/pubkeys"
    ];
  });
in {
  options.hardware.wifi = {
    enable = mkEnableOption ''
      Wifi hacks
    '';
    interface = mkOption {
      type = types.str;
    };
  };

  config = mkIf cfg.enable {
    services.hostapd.noScan = true;
    systemd.services.hostapd.preStart = '' 
      set +e 
      ${pkgs.wirelesstools}/bin/iwconfig ${cfg.interface} power off
      true
    '';
  };
}
