# Small seedbox setup.
#
# Inspired by [1]
#
# [1]: https://github.com/delroth/infra.delroth.net/blob/master/roles/seedbox.nix
{ config, lib, pkgs, ... }:
let
  cfg = config.my.services.transmission;
in
{
  options.my.services.transmission = with lib; {
    enable = mkEnableOption "Transmission torrent client";

    credentialsFile = mkOption {
      type = types.str;
      example = "/var/lib/transmission/creds.json";
      description = ''
        Credential file as an json configuration file to be merged with
        the main one.
      '';
    };

    downloadBase = mkOption {
      type = types.str;
      default = "/data/downloads";
      example = "/var/lib/transmission/download";
      description = "Download base directory";
    };

    port = mkOption {
      type = types.port;
      default = 9091;
      example = 8080;
      description = "Internal port for webui";
    };

    peerPort = mkOption {
      type = types.port;
      default = 30251;
      example = 32323;
      description = "Peering port";
    };
  };

  config = lib.mkIf cfg.enable {
    services.transmission = {
      enable = true;
      package = pkgs.transmission_4;
      group = "media";
      webHome = pkgs.trgui-ng-web;

      downloadDirPermissions = "775";

      inherit (cfg) credentialsFile;

      settings = {
        download-dir = "${cfg.downloadBase}/complete";
        incomplete-dir = "${cfg.downloadBase}/incomplete";

        peer-port = cfg.peerPort;

        rpc-enabled = true;
        rpc-port = cfg.port;
        rpc-authentication-required = true;

        # Proxied behind Nginx.
        rpc-whitelist-enabled = true;
        rpc-whitelist = "127.0.0.1";

        umask = "002"; # To go with `downloadDirPermissions`
      };
    };

    systemd.services.transmission = {
      serviceConfig = {
        # Transmission wants to eat *all* my RAM if left to its own devices
        MemoryMax = "33%";
        # Avoid errors due to high number of open files.
        LimitNOFILE = 1048576;
        # Longer stop timeout to finish all torrents
        TimeoutStopSec = "5m";
      };
    };

    # Set-up media group
    users.groups.media = { };

    # Default transmission webui, I prefer combustion but its development
    # seems to have stalled
    my.services.nginx.virtualHosts = {
      transmission = {
        inherit (cfg) port;
      };
    };

    networking.firewall = {
      allowedTCPPorts = [ cfg.peerPort ];
      allowedUDPPorts = [ cfg.peerPort ];
    };

    # NOTE: unfortunately transmission does not log connection failures for fail2ban
  };
}
