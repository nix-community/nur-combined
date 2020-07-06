{ config, lib, pkgs, ... }:

with lib;
let
  cfg = config.programs.crc;
in
{
  options = {
    programs.crc = {
      enable = mkOption { default = false; description = "wether to enable crc"; type = types.bool; };
      package = mkOption {
        default = pkgs.my.crc; # FIXME use pkgs.crc at some point
        description = "crc package to be used";
        type = types.package;
      };
    };
  };

  config = mkIf cfg.enable {
    environment.systemPackages = with pkgs; [ cfg.package ];
    networking.networkmanager.dns = "dnsmasq";
    environment.etc."NetworkManager/dnsmasq.d/crc.conf".text = ''
      server=/apps-crc.testing/192.168.130.11
      server=/crc.testing/192.168.130.11
    '';
  };
}
