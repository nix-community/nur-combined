{ config, lib, pkgs, ... }:

with lib;

let

  cfg = config.kampka.services.ntp;

in
{
  options.kampka.services.ntp = {
    enable = mkEnableOption "NTP service";

    allowAddress = mkOption {
      type = types.listOf types.str;
      default = [];
      example = [ "10.10.0.1" "10.20.0.0/16" ];
      description = "IP addresses or ranges that are allowed to synchronize from this service";
    };

    timeServers = lib.mkOption {
      type = types.listOf types.str;
      default = [
        "ptbtime1.ptb.de"
        "ptbtime2.ptb.de"
        "ptbtime3.ptb.de"
      ];
      description = ''
        The list of time servers used.
      '';
    };
  };


  config = mkIf cfg.enable {
    networking.timeServers = cfg.timeServers;

    services.ntp.enable = false;
    services.timesyncd.enable = false;
    services.chrony.enable = true;
    services.chrony.extraConfig = ''
      logchange 0.5
      mailonchange root 0.5

      dumponexit

      ${optionalString (cfg.allowAddress != []) "local stratum 10" }
      ${concatStringsSep "\n" (map (address: "allow ${address}") cfg.allowAddress)}

    '';
  };
}
