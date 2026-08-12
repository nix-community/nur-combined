{ config, lib, pkgs, options, ... }:

with lib;

let
  pkg = pkgs.callPackage ../pkgs/prometheus-lnd-exporter.nix {};
  cfg = config.services.prometheus-exporters-lnd;
in
{
  options.services.prometheus-exporters-lnd = {
    enable = mkEnableOption "the prometheus lnd (Lightning Network Daemon) exporter";

    lndHost = mkOption {
      type = types.str;
      default = "localhost:10009";
      description = ''
        lnd instance gRPC address:port.
      '';
    };

    lndTlsPath = mkOption {
      type = types.path;
      description = ''
        Path to lnd TLS certificate.
      '';
    };

    lndMacaroonDir = mkOption {
      type = types.path;
      description = ''
        Path to lnd macaroons.
      '';
    };

    extraFlags = mkOption {
      type = types.listOf types.str;
      default = [];
      description = ''
        Extra commandline options to pass to the lnd exporter.
      '';
    };

    listenAddress = mkOption {
      type = types.str;
      default = "0.0.0.0";
      description = ''
        Address to listen on.
      '';
    };

    port = mkOption {
      type = types.int;
      default = 9092;
      description = ''
        Port to listen on.
      '';
    };

    openFirewall = mkOption {
      type = types.bool;
      default = false;
      description = ''
        Open port in firewall for incoming connections.
      '';
    };

    firewallFilter = mkOption {
      type = types.str;
      default = "-p tcp -m tcp --dport ${toString cfg.port}";
      example = literalExample ''
        "-i eth0 -p tcp -m tcp --dport ${toString cfg.port}"
      '';
    };

    user = mkOption {
      type = types.str;
      default = "lnd-exporter";
    };

    group = mkOption {
      type = types.str;
      default = "lnd-exporter";
    };
  };

  config = mkIf cfg.enable {
    networking.firewall.extraCommands = mkIf cfg.openFirewall (concatStrings [
      "ip46tables -A nixos-fw ${cfg.firewallFilter} "
      "-m comment --comment lnd-exporter -j nixos-fw-accept"
    ]);
    systemd.services."prometheus-lnd-exporter" = {
      wantedBy = [ "multi-user.target" ];
      after = [ "network.target" ];
      serviceConfig.Restart = mkDefault "always";
      serviceConfig.PrivateTmp = mkDefault true;
      serviceConfig.WorkingDirectory = mkDefault "/tmp";
      serviceConfig.DynamicUser = mkDefault true;
      serviceConfig.User = cfg.user;
      serviceConfig.Group = cfg.group;
      serviceConfig.ExecStart = ''
        ${pkg}/bin/lndmon \
          --prometheus.listenaddr=${cfg.listenAddress}:${toString cfg.port} \
          --prometheus.logdir=/var/log/prometheus-lnd-exporter \
          --lnd.host=${cfg.lndHost} \
          --lnd.tlspath=${cfg.lndTlsPath} \
          --lnd.macaroondir=${cfg.lndMacaroonDir} \
          ${concatStringsSep " \\\n  " cfg.extraFlags}
      '';
      serviceConfig.LogsDirectory = "prometheus-lnd-exporter";
    };
  };
}
