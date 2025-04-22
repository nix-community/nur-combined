# based on nixpkgs/nixos/modules/services/monitoring/prometheus/exporters/deluge.nix

{ config, lib, pkgs, ... }:

let
  cfg = config.services.prometheus.exporters.qbittorrent;
  inherit (lib) mkOption mkPackageOption types concatStringsSep;
in
{
  port = 9355;

  extraOpts = {
    package = mkPackageOption pkgs "prometheus-qbittorrent-exporter" { };

    qbittorrentHost = mkOption {
      type = types.str;
      default = "localhost";
      description = ''
        Hostname where qbittorrent is running.
      '';
    };

    qbittorrentPort = mkOption {
      type = types.port;
      # TODO default?
      default = 1952;
      description = ''
        Port where qbittorrent is listening.
      '';
    };

    qbittorrentUser = mkOption {
      type = types.str;
      default = "admin";
      description = ''
        User to connect to qbittorrent.
      '';
    };

    qbittorrentPassword = mkOption {
      type = types.nullOr types.str;
      default = null;
      description = ''
        Password to connect to qbittorrent.

        This stores the password unencrypted in the nix store and is thus considered unsafe. Prefer
        using the qbittorrentPasswordFile option.
      '';
    };

    qbittorrentPasswordFile = mkOption {
      type = types.nullOr types.path;
      default = null;
      description = ''
        File containing the password to connect to qbittorrent.
      '';
    };

    /*
    exportPerTorrentMetrics = mkOption {
      type = types.bool;
      default = false;
      description = ''
        Enable per-torrent metrics.

        This may significantly increase the number of time series depending on the number of
        torrents in your qbittorrent instance.
      '';
    };
    */
  };
  serviceOpts = {
    serviceConfig = {
      ExecStart = ''
        ${cfg.package}/bin/qbittorrent-exporter
      '';
      Environment = [
        "QBITTORRENT_HOST=${cfg.qbittorrentHost}"
        "QBITTORRENT_PORT=${toString cfg.qbittorrentPort}"
        # Whether to use SSL to connect or not. Will be forced to True when using port 443
        "QBITTORRENT_SSL=False"
        # qbittorrent server path or base URL
        "QBITTORRENT_URL_BASE="
        "QBITTORRENT_USER=${cfg.qbittorrentUser}"
        # https://github.com/esanchezm/prometheus-qbittorrent-exporter/issues/41
        "EXPORTER_ADDRESS=${toString cfg.listenAddress}"
        "EXPORTER_PORT=${toString cfg.port}"
        # Log level. One of: DEBUG, INFO, WARNING, ERROR, CRITICAL
        "EXPORTER_LOG_LEVEL=INFO"
        # Prefix to add to all the metrics
        "METRICS_PREFIX=qbittorrent"
        # Whether to verify SSL certificate when connecting to the qbittorrent server. Any other value but True will disable the verification
        "VERIFY_WEBUI_CERTIFICATE=True"
      ] ++ lib.optionals (cfg.qbittorrentPassword != null) [
        "QBITTORRENT_PASS=${cfg.qbittorrentPassword}"
      ];
      EnvironmentFile = lib.optionalString (cfg.qbittorrentPasswordFile != null) "/etc/qbittorrent-exporter/password";
    };
  };
}
