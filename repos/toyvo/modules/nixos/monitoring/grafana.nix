{
  config,
  lib,
  homelab,
  ...
}:
let
  cfg = config.services.monitoring;
  inherit (config.networking) hostName;
in
{
  options.services.monitoring.grafana = {
    enable = lib.mkEnableOption "Grafana dashboard server";
  };

  config = lib.mkIf cfg.grafana.enable {
    services.grafana = {
      enable = true;
      settings = {
        server = {
          http_addr = "0.0.0.0";
          http_port = homelab.${hostName}.services.grafana.port;
          domain = "grafana.diekvoss.net";
          root_url = "https://grafana.diekvoss.net";
        };
        security = {
          admin_user = "admin";
          admin_password = "$__file{${config.sops.secrets."grafana-admin-password".path}}";
          secret_key = "$__file{${config.sops.secrets."grafana-secret-key".path}}";
        };
      };

      provision = {
        enable = true;
        datasources.settings.datasources = [
          {
            name = "Prometheus";
            type = "prometheus";
            url = "http://localhost:9090";
            isDefault = true;
            access = "proxy";
          }
          {
            name = "Loki";
            type = "loki";
            url = "http://localhost:3101";
            access = "proxy";
          }
          {
            name = "Tempo";
            type = "tempo";
            url = "http://localhost:3200";
            access = "proxy";
          }
        ];
      };
    };

    networking.firewall.allowedTCPPorts = [
      (homelab.${hostName}.services.grafana.port)
    ];
  };
}
