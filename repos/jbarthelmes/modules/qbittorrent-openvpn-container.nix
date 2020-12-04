{ config, lib, pkgs, ... }:

with lib;

let cfg = config.services.qbvpn;
in {
  options.services.qbvpn = {
    enable = mkEnableOption "qBittorrent + OpenVPN inside Docker";

    webuiPort = mkOption {
      type = types.int;
      default = 8080;
      description = "WebUI TCP port";
    };

    bittorrentPort = mkOption {
      type = types.int;
      default = 8999;
      description = "Bittorrent TCP+UDP ports";
    };

    configDir = mkOption {
      type = types.path;
      default = "/var/qbittorrent/etc";
      description = "Config directory";
    };

    downloadDir = mkOption {
      type = types.path;
      default = "/var/qbittorrent/downloads";
      description = "Download directory";
    };
  };

  config = mkIf cfg.enable {
    docker-containers.qbittorrent-openvpn = {
      extraDockerOptions = [ "--privileged" ];
      volumes = [ "${cfg.configDir}:/config" "${cfg.downloadDir}:/downloads" ];
      environment = {
        VPN_ENABLED = "yes";
        LAN_NETWORK = "192.168.0.0/24";
      };
      ports = [
        "${toString cfg.webuiPort}:8080"
        "${toString cfg.bittorrentPort}:8999"
        "${toString cfg.bittorrentPort}:8999/udp"
      ];
      image = "markusmcnugen/qbittorrentvpn";
    };
    networking.firewall = {
      allowedTCPPorts = [ cfg.webuiPort cfg.bittorrentPort ];
      allowedUDPPorts = [ cfg.bittorrentPort ];
    };
  };
}
