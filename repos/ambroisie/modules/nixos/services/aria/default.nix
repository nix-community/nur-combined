{ config, lib, pkgs, ... }:
let
  cfg = config.my.services.aria;
in
{
  options.my.services.aria = with lib; {
    enable = mkEnableOption "";

    rpcSecretFile = mkOption {
      type = types.str;
      example = "/run/secrets/aria-secret.txt";
      description = ''
        File containing the RPC secret.
      '';
    };

    rpcPort = mkOption {
      type = types.port;
      default = 6800;
      example = 8080;
      description = "RPC port";
    };

    downloadDir = mkOption {
      type = types.str;
      default = "/data/downloads";
      example = "/var/lib/transmission/download";
      description = "Download directory";
    };
  };

  config = lib.mkIf cfg.enable {
    services.aria2 = {
      enable = true;

      inherit (cfg) downloadDir rpcSecretFile;

      rpcListenPort = cfg.rpcPort;
      openPorts = false; # I don't want to expose the RPC port
    };

    # Expose DHT ports
    networking.firewall = {
      # FIXME: check for overlap?
      allowedUDPPortRanges = config.services.aria2.listenPortRange;
    };

    # Set-up media group
    users.groups.media = { };

    systemd.services.aria2 = {
      serviceConfig = {
        Group = lib.mkForce "media"; # Use 'media' group
      };
    };

    my.services.nginx.virtualHosts = {
      aria = {
        root = "${pkgs.ariang}/share/ariang";
        # For paranoia, don't allow anybody to use the UI unauthenticated
        sso = {
          enable = true;
        };
      };
      aria-rpc = {
        port = cfg.rpcPort;
        # Proxy websockets for RPC
        websocketsLocations = [ "/" ];
      };
    };

    # NOTE: unfortunately aria2 does not log connection failures for fail2ban
  };
}
