self:
{ config, lib, pkgs, ... }:
with lib;
let
  cfg = config.services.prometheus-nftables-exporter;
  name = "nftables";
  package = self.legacyPackages.${pkgs.stdenv.hostPlatform.system}.prometheus-nftables-exporter;
  configFile = pkgs.writeText "nftables_exporter.yaml" (builtins.toJSON {
    nftables_exporter = {
      bind_to = "${cfg.listenAddress}:${toString cfg.port}";
      url_path = "/metrics";
      nft_location = "${pkgs.nftables}/bin/nft";
    };
  });
in
{
  options.services.prometheus-nftables-exporter = with types; mkOption {
    type = types.submodule {
      options = {
        enable = mkEnableOption "the prometheus ${name} exporter";
        enableLocalScraping = mkEnableOption "enable scraping by local prometheus";
        port = mkOption {
          type = types.port;
          default = 9630;
          description = ''
            Port to listen on.
          '';
        };
        listenAddress = mkOption {
          type = types.str;
          default = "127.0.0.1";
          description = ''
            Address to listen on.
          '';
        };
        user = mkOption {
          type = types.str;
          default = "${name}-exporter";
          description = ''
            User name under which the ${name} exporter shall be run.
          '';
        };
        group = mkOption {
          type = types.str;
          default = "${name}-exporter";
          description = ''
            Group under which the ${name} exporter shall be run.
          '';
        };
      };
    };
    default = { };
  };
  config = mkIf cfg.enable {
    users.users."${cfg.user}" = {
      description = "Prometheus ${name} exporter service user";
      isSystemUser = true;
      group = "${cfg.group}";
    };
    users.groups."${cfg.group}" = { };

    systemd.services."prometheus-${name}-exporter" = {
      wantedBy = [ "multi-user.target" ];
      after = [ "network.target" ];
      serviceConfig = {
        Restart = "always";
        PrivateTmp = true;
        WorkingDirectory = "/tmp";
        DynamicUser = false;
        User = cfg.user;
        Group = cfg.group;
        AmbientCapabilities = [ "CAP_NET_ADMIN" ];
        ExecStart = "${getBin package}/bin/nftables-exporter -config ${configFile}";
      };
    };

    services.prometheus.scrapeConfigs = mkIf cfg.enableLocalScraping [
      {
        job_name = "${name}";
        honor_labels = true;
        static_configs = [{
          targets = [ "127.0.0.1:${toString cfg.port}" ];
        }];
      }
    ];
  };
}
