{
  config,
  lib,
  ...
}:
let
  cfg = config.services.wireguard-tunnel;
in
{
  options.services.wireguard-tunnel = {
    enable = lib.mkEnableOption "WireGuard point-to-point tunnel";

    role = lib.mkOption {
      type = lib.types.enum [
        "server"
        "peer"
      ];
      description = "Whether this machine is the WireGuard server or a peer";
    };

    listenPort = lib.mkOption {
      type = lib.types.port;
      default = 51820;
      description = "WireGuard listen port (server only)";
    };

    address = lib.mkOption {
      type = lib.types.str;
      description = "This machine's IP on the WireGuard subnet (e.g., 10.100.0.1/24)";
    };

    privateKeySecret = lib.mkOption {
      type = lib.types.str;
      description = "Name of the sops secret containing the WireGuard private key";
    };

    peerPublicKey = lib.mkOption {
      type = lib.types.str;
      description = "Public key of the remote peer";
    };

    peerEndpoint = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      default = null;
      description = "Endpoint of the remote peer (host:port). Required for peer role.";
    };

    peerAllowedIPs = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      description = "AllowedIPs for the remote peer";
    };
  };

  config = lib.mkIf cfg.enable {
    networking.wireguard.interfaces.wg0 = {
      ips = [ cfg.address ];
      listenPort = lib.mkIf (cfg.role == "server") cfg.listenPort;
      privateKeyFile = config.sops.secrets.${cfg.privateKeySecret}.path;
      peers = [
        (
          {
            publicKey = cfg.peerPublicKey;
            allowedIPs = cfg.peerAllowedIPs;
            persistentKeepalive = 25;
          }
          // lib.optionalAttrs (cfg.peerEndpoint != null) {
            endpoint = cfg.peerEndpoint;
          }
        )
      ];
    };

    networking.firewall.allowedUDPPorts = lib.mkIf (cfg.role == "server") [
      cfg.listenPort
    ];
  };
}
