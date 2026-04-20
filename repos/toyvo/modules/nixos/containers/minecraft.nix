{
  config,
  lib,
  pkgs,
  homelab,
  inputs,
  ...
}:
let
  cfg = config.containerPresets.minecraft;
in
{
  options.containerPresets.minecraft = {
    enable = lib.mkEnableOption "Minecraft NixOS container";

    hostAddress = lib.mkOption {
      type = lib.types.str;
      default = "10.200.1.1";
      description = "Host side of the veth pair";
    };

    localAddress = lib.mkOption {
      type = lib.types.str;
      default = "10.200.1.2";
      description = "Container IP address";
    };

    natInterface = lib.mkOption {
      type = lib.types.str;
      description = "Host WAN-facing network interface for NAT masquerade and port forwarding";
    };

    stateDir = lib.mkOption {
      type = lib.types.path;
      default = "/var/lib/minecraft";
      description = "Host path bind-mounted into the container at /var/lib/minecraft";
    };

    minecraftUid = lib.mkOption {
      type = lib.types.int;
      default = 355;
      description = "Pinned UID for the minecraft user (static, below 400; chown stateDir to this UID before first start)";
    };

    minecraftGid = lib.mkOption {
      type = lib.types.int;
      default = 355;
      description = "Pinned GID for the minecraft group (static, below 400; chown stateDir to this GID before first start)";
    };

    settings = lib.mkOption {
      type = lib.types.attrs;
      default = { };
      description = "Settings merged into services.minecraft-server. eula = true and openFirewall = true are always set.";
    };

    ports = {
      server = lib.mkOption {
        type = lib.types.port;
        default = 25565;
        description = "Minecraft Java Edition listen port";
      };
      serverAlt = lib.mkOption {
        type = lib.types.port;
        default = 25566;
        description = "Alternate Java Edition port (e.g. lazymc query)";
      };
      bedrock = lib.mkOption {
        type = lib.types.port;
        default = 19132;
        description = "Minecraft Bedrock Edition UDP port";
      };
      voiceMod = lib.mkOption {
        type = lib.types.port;
        default = 24454;
        description = "Simple Voice Chat mod UDP port";
      };
      http = lib.mkOption {
        type = lib.types.port;
        default = 7878;
        description = "HTTP port for in-game map viewers or status pages (proxied by Caddy on the host)";
      };
    };
  };

  config = lib.mkIf cfg.enable {
    services.monitoring.containerJournals = [ "minecraft" ];
    networking.nat = {
      enable = true;
      externalInterface = cfg.natInterface;
      internalInterfaces = [ "ve-minecraft" ];
      # Forward game ports from the host's public interface into the container
      forwardPorts = [
        {
          sourcePort = cfg.ports.server;
          proto = "tcp";
          destination = "${cfg.localAddress}:${toString cfg.ports.server}";
        }
        {
          sourcePort = cfg.ports.server;
          proto = "udp";
          destination = "${cfg.localAddress}:${toString cfg.ports.server}";
        }
        {
          sourcePort = cfg.ports.serverAlt;
          proto = "tcp";
          destination = "${cfg.localAddress}:${toString cfg.ports.serverAlt}";
        }
        {
          sourcePort = cfg.ports.bedrock;
          proto = "udp";
          destination = "${cfg.localAddress}:${toString cfg.ports.bedrock}";
        }
        {
          sourcePort = cfg.ports.voiceMod;
          proto = "udp";
          destination = "${cfg.localAddress}:${toString cfg.ports.voiceMod}";
        }
      ];
    };

    # Open host firewall so forwarded packets reach the NAT rules
    networking.firewall = {
      allowedTCPPorts = [
        cfg.ports.server
        cfg.ports.serverAlt
      ];
      allowedUDPPorts = [
        cfg.ports.server
        cfg.ports.bedrock
        cfg.ports.voiceMod
      ];
    };

    systemd.tmpfiles.rules = [
      "d /var/lib/nixos-containers/minecraft/var/log/journal 0755 root systemd-journal -"
    ];

    containers.minecraft = {
      autoStart = true;
      extraFlags = [ "--link-journal=guest" ];
      privateNetwork = true;
      hostAddress = cfg.hostAddress;
      localAddress = cfg.localAddress;

      # Pass inputs through so the custom minecraft module (with lazymc, tmux,
      # and disabledModules override) can be imported inside the container.
      specialArgs = { inherit inputs; };

      bindMounts = {
        "/var/lib/minecraft" = {
          hostPath = cfg.stateDir;
          isReadOnly = false;
        };
      };

      config =
        { config, inputs, ... }:
        {
          # Pin UID/GID to match stateDir ownership on the host
          users.users.minecraft.uid = lib.mkForce cfg.minecraftUid;
          users.groups.minecraft.gid = lib.mkForce cfg.minecraftGid;

          services.minecraft-server = lib.recursiveUpdate {
            enable = true;
            eula = true;
            openFirewall = true;
          } cfg.settings;

          system.stateVersion = "26.05";
        };
    };
  };
}
