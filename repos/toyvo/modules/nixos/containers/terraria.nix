{
  config,
  lib,
  homelab,
  ...
}:
let
  cfg = config.containerPresets.terraria;
in
{
  options.containerPresets.terraria = {
    enable = lib.mkEnableOption "Terraria NixOS container";

    hostAddress = lib.mkOption {
      type = lib.types.str;
      default = "10.200.1.5";
      description = "Host side of the veth pair";
    };

    localAddress = lib.mkOption {
      type = lib.types.str;
      default = "10.200.1.6";
      description = "Container IP address";
    };

    natInterface = lib.mkOption {
      type = lib.types.str;
      description = "Host WAN-facing network interface for NAT masquerade and port forwarding";
    };

    stateDir = lib.mkOption {
      type = lib.types.path;
      default = "/var/lib/terraria";
      description = "Host path bind-mounted into the container at /var/lib/terraria";
    };

    settings = lib.mkOption {
      type = lib.types.attrs;
      default = { };
      description = "Settings merged into services.terraria. openFirewall = true is always set.";
    };

    port = lib.mkOption {
      type = lib.types.port;
      default = 7777;
      description = "Terraria server listen port (TCP + UDP)";
    };

    restPort = lib.mkOption {
      type = lib.types.port;
      default = 7878;
      description = "TShock REST API port (proxied by Caddy on the host)";
    };
  };

  config = lib.mkIf cfg.enable {
    networking.nat = {
      enable = true;
      externalInterface = cfg.natInterface;
      internalInterfaces = [ "ve-terraria" ];
      forwardPorts = [
        {
          sourcePort = cfg.port;
          proto = "tcp";
          destination = "${cfg.localAddress}:${toString cfg.port}";
        }
        {
          sourcePort = cfg.port;
          proto = "udp";
          destination = "${cfg.localAddress}:${toString cfg.port}";
        }
      ];
    };

    networking.firewall = {
      allowedTCPPorts = [ cfg.port ];
      allowedUDPPorts = [ cfg.port ];
    };

    containers.terraria = {
      autoStart = true;
      privateNetwork = true;
      hostAddress = cfg.hostAddress;
      localAddress = cfg.localAddress;

      bindMounts = {
        "/var/lib/terraria" = {
          hostPath = cfg.stateDir;
          isReadOnly = false;
        };
      };

      config =
        { ... }:
        {
          nixpkgs.config.allowUnfree = true;

          # services.terraria uses the registered nixpkgs UID/GID 253 — no custom pinning needed
          services.terraria = lib.recursiveUpdate {
            enable = true;
            openFirewall = true;
            dataDir = "/var/lib/terraria";
          } cfg.settings;

          # TShock REST API — host Caddy proxies to this port directly via container IP
          networking.firewall.allowedTCPPorts = [ cfg.restPort ];

          system.stateVersion = "26.05";
        };
    };
  };
}
