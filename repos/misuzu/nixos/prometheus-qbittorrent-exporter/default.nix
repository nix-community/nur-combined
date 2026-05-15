{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.services.prometheus-qbittorrent-exporter;
in
{
  options.services.prometheus-qbittorrent-exporter = {
    enable = lib.mkEnableOption "Prometheus exporter for qBittorrent";
    package = lib.mkPackageOption pkgs "prometheus-qbittorrent-exporter" { };
    port = lib.mkOption {
      type = lib.types.port;
      default = 9631;
      description = ''
        Port to listen on.
      '';
    };
    listenAddress = lib.mkOption {
      type = lib.types.str;
      default = "0.0.0.0";
      description = ''
        Address to listen on.
      '';
    };
    openFirewall = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = ''
        Open port in firewall for incoming connections.
      '';
    };
    settings = lib.mkOption {
      type = lib.types.attrs;
      description = ''
        qbittorrent-exporter configuration as nix attribute set.

        See <https://github.com/martabal/qbittorrent-exporter/blob/main/.env.example>
        for available options.
      '';
      example = lib.literalExpression ''
        {
          QBITTORRENT_BASE_URL = "http://127.0.0.1:8080";
        }
      '';
    };
    environmentFile = lib.mkOption {
      type = lib.types.nullOr lib.types.path;
      default = null;
      example = "/root/prometheus-qbittorrent-exporter.env";
      description = ''
        Environment file as defined in {manpage}`systemd.exec(5)`.

        See <https://github.com/martabal/qbittorrent-exporter/blob/main/.env.example>
        for available options.
      '';
    };
  };
  config = lib.mkIf cfg.enable {
    networking.firewall.allowedTCPPorts = lib.mkIf cfg.openFirewall [ cfg.port ];
    services.prometheus-qbittorrent-exporter.settings = {
      EXPORTER_PORT = toString cfg.port;
      EXPORTER_HOST = cfg.listenAddress;
    };
    systemd.services.prometheus-qbittorrent-exporter = {
      description = "Prometheus exporter for qBittorrent";
      after = [ "network.target" ];
      wantedBy = [ "multi-user.target" ];
      environment = cfg.settings;
      serviceConfig = {
        DynamicUser = true;
        EnvironmentFile = lib.mkIf (cfg.environmentFile != null) [ cfg.environmentFile ];
        ExecStart = lib.getExe cfg.package;
        Restart = "always";
      };
    };
  };
}
