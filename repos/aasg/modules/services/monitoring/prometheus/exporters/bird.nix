{ config, lib, pkgs, ... }:
let
  inherit (lib) concatStringsSep mkEnableOption mkIf mkOption optionalString types;

  cfg = config.services.prometheus.birdExporter;
in
{

  options = {
    services.prometheus.birdExporter = {
      enable = mkEnableOption "the prometheus bird exporter";
      port = mkOption {
        description = "Port to listen on.";
        type = types.port;
        default = 9324;
      };
      listenAddress = mkOption {
        description = "Address to listen on.";
        type = types.str;
        default = "0.0.0.0";
      };
      extraFlags = mkOption {
        description = "Extra commandline options to pass to the bird exporter.";
        type = types.listOf types.str;
        default = [ ];
      };
      group = mkOption {
        type = types.str;
        default = "bird-exporter";
        description = "Group under which the bird exporter shall be run.";
      };
      birdVersion = mkOption {
        description = "Version of Bird to scrape.";
        type = types.enum [ "v1.ip4" "v1.ip6" "v1.ip46" "v2" ];
      };
    };
  };

  config = mkIf cfg.enable {
    systemd.services.prometheus-bird-exporter = {
      wantedBy = [ "multi-user.target" ];
      after = [ "network.target" "bird.service" "bird6.service" "bird2.service" ];
      serviceConfig = {
        ExecStart = ''
          ${pkgs.prometheus-bird-exporter}/bin/bird_exporter -format.new \
            ${optionalString (cfg.birdVersion == "v1.ip4" || cfg.birdVersion == "v1.ip46") "-bird.ipv4"} \
            ${optionalString (cfg.birdVersion == "v1.ip6" || cfg.birdVersion == "v1.ip46") "-bird.ipv6"} \
            ${optionalString (cfg.birdVersion == "v2") "-bird.v2"} \
            -web.listen-address ${cfg.listenAddress}:${toString cfg.port} \
            ${concatStringsSep " \\\n  " cfg.extraFlags}
        '';
        Restart = "always";
        PrivateTmp = true;
        DynamicUser = true;
        Group = cfg.group;
      };
    };

  };

}
