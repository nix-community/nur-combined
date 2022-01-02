{ config, lib, pkgs, options, ... }:

with lib;

let

  cfg = config.services.prometheus.nats-exporter;

in

{

  options.services.prometheus.nats-exporter = {
    enable = mkEnableOption "the prometheus nats exporter";

    package = mkOption {
      type = types.package;
      default = pkgs.my-nur.prometheus-nats-exporter;
    };

    port = mkOption {
      type = types.int;
      default = 7777;
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
    url = mkOption {
      type = types.str;
      default = "http://127.0.0.1:8222";
      description = ''
        NATS monitor endpoint to query.
      '';
    };
    extraFlags = mkOption {
      type = types.listOf types.str;
      default = [];
      description = ''
        Extra command line flags to pass to the exporter. See:
        <link>https://github.com/nats-io/prometheus-nats-exporter#usage</link>
      '';
    };
  };

  config = mkIf cfg.enable {
    systemd.services."prometheus-nats-exporter" = {
      wantedBy = [ "multi-user.target" ];
      after = [ "network.target" ];
      serviceConfig = {
        Restart = "always";
        PrivateTmp = true;
        WorkingDirectory = /tmp;
        DynamicUser = true;
        ExecStart = ''
          ${cfg.package}/bin/prometheus-nats-exporter \
            -addr ${cfg.listenAddress} \
            -port ${toString cfg.port} \
            ${concatStringsSep " \\\n  " cfg.extraFlags} \
            ${cfg.url}
        '';
      };
    };
  };
}
