{ config, lib, pkgs, options, ... }:

with lib;

let

  cfg = config.services.prometheus.unbound-exporter;

in

{

  options.services.prometheus.unbound-exporter = {
    enable = mkEnableOption "the prometheus unbound exporter";
    port = mkOption {
      type = types.int;
      default = 9167;
      description = ''
        Port to listen on.
      '';
    };
    listenAddress = mkOption {
      type = types.str;
      default = "0.0.0.0";
      description = ''
        Address to listen on.
      '';
    };
    serverCA = mkOption {
      type = types.str;
    };
    controlCert = mkOption {
      type = types.str;
    };
    controlKey = mkOption {
      type = types.str;
    };
  };

  config = mkIf cfg.enable {
    systemd.services."prometheus-unbound-exporter" = {
      wantedBy = [ "multi-user.target" ];
      after = [ "network.target" ];
      serviceConfig = {
        Restart = "always";
        PrivateTmp = true;
        WorkingDirectory = /tmp;
        User = "unbound";
        Group = "nogroup";
        Environment = "GODEBUG=x509ignoreCN=0";
        ExecStart = ''
          ${pkgs.prometheus-unbound-exporter}/bin/unbound_exporter \
            -web.listen-address ${cfg.listenAddress}:${toString cfg.port} \
            -unbound.ca ${cfg.serverCA} \
            -unbound.cert ${cfg.controlCert} \
            -unbound.key ${cfg.controlKey}
        '';
      };
    };
  };
}
