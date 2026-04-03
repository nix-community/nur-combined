{ config, lib, homelab, ... }:
let
  cfg = config.containerPresets.starr;
in
{
  options.containerPresets.starr = {
    enable = lib.mkEnableOption "Starr suite NixOS container";

    hostAddress = lib.mkOption {
      type = lib.types.str;
      description = "Host side of the veth pair";
    };

    localAddress = lib.mkOption {
      type = lib.types.str;
      description = "Container IP address";
    };

    natInterface = lib.mkOption {
      type = lib.types.str;
      description = "Host LAN-facing network interface for NAT masquerade (e.g. eno1, enp2s0). Discover with: ip route get 1.1.1.1";
    };

    stateDir = lib.mkOption {
      type = lib.types.path;
      default = "/var/lib/nixos-containers/starr";
      description = "Base directory containing per-service state subdirectories";
    };

    mediaDir = lib.mkOption {
      type = lib.types.path;
      default = "/var/lib/nixos-containers/starr";
      description = "Media pool path bind-mounted read-write into the container";
    };

    multimediaGid = lib.mkOption {
      type = lib.types.int;
      default = 976;
      description = "Pinned GID for the multimedia group on both host and container";
    };

    ports = {
      bazarr = lib.mkOption {
        type = lib.types.port;
        default = homelab.starr.services.bazarr.port;
        description = "Bazarr listen port";
      };
      flaresolverr = lib.mkOption {
        type = lib.types.port;
        default = homelab.starr.services.flaresolverr.port;
        description = "FlareSolverr listen port";
      };
      lidarr = lib.mkOption {
        type = lib.types.port;
        default = homelab.starr.services.lidarr.port;
        description = "Lidarr listen port";
      };
      prowlarr = lib.mkOption {
        type = lib.types.port;
        default = homelab.starr.services.prowlarr.port;
        description = "Prowlarr listen port";
      };
      radarr = lib.mkOption {
        type = lib.types.port;
        default = homelab.starr.services.radarr.port;
        description = "Radarr listen port";
      };
      readarr = lib.mkOption {
        type = lib.types.port;
        default = homelab.starr.services.readarr.port;
        description = "Readarr listen port";
      };
      sonarr = lib.mkOption {
        type = lib.types.port;
        default = homelab.starr.services.sonarr.port;
        description = "Sonarr listen port";
      };
    };
  };

  config = lib.mkIf cfg.enable {
    # Pin multimedia GID so bind-mounted paths are accessible from inside the container
    users.groups.multimedia.gid = cfg.multimediaGid;

    # NAT masquerade so the container can reach external indexers (Prowlarr, FlareSolverr)
    networking.nat = {
      enable = true;
      externalInterface = cfg.natInterface;
      internalInterfaces = [ "ve-starr" ];
    };

    containers.starr = {
      autoStart = true;
      privateNetwork = true;
      hostAddress = cfg.hostAddress;
      localAddress = cfg.localAddress;

      bindMounts = {
        "/mnt/Books" = {
          hostPath = "${cfg.mediaDir}/Books";
          isReadOnly = false;
        };
        "/mnt/Movies" = {
          hostPath = "${cfg.mediaDir}/Movies";
          isReadOnly = false;
        };
        "/mnt/Music" = {
          hostPath = "${cfg.mediaDir}/Music";
          isReadOnly = false;
        };
        "/mnt/TV Shows" = {
          hostPath = "${cfg.mediaDir}/TV Shows";
          isReadOnly = false;
        };
        "/var/lib/bazarr" = {
          hostPath = "${cfg.stateDir}/bazarr";
          isReadOnly = false;
        };
        "/var/lib/lidarr" = {
          hostPath = "${cfg.stateDir}/lidarr";
          isReadOnly = false;
        };
        "/var/lib/prowlarr" = {
          hostPath = "${cfg.stateDir}/prowlarr";
          isReadOnly = false;
        };
        "/var/lib/radarr" = {
          hostPath = "${cfg.stateDir}/radarr";
          isReadOnly = false;
        };
        "/var/lib/readarr" = {
          hostPath = "${cfg.stateDir}/readarr";
          isReadOnly = false;
        };
        "/var/lib/sonarr" = {
          hostPath = "${cfg.stateDir}/sonarr";
          isReadOnly = false;
        };
      };

      config =
        { ... }:
        {
          # Must match host GID so bind-mounted paths are writable
          users.groups.multimedia.gid = cfg.multimediaGid;

          services = {
            bazarr = {
              enable = true;
              openFirewall = true;
              group = "multimedia";
              listenPort = cfg.ports.bazarr;
            };
            flaresolverr = {
              enable = true;
              openFirewall = true;
              port = cfg.ports.flaresolverr;
            };
            lidarr = {
              enable = true;
              openFirewall = true;
              group = "multimedia";
              settings.server.port = cfg.ports.lidarr;
            };
            prowlarr = {
              enable = true;
              openFirewall = true;
              settings.server.port = cfg.ports.prowlarr;
            };
            radarr = {
              enable = true;
              openFirewall = true;
              group = "multimedia";
              settings.server.port = cfg.ports.radarr;
            };
            readarr = {
              enable = true;
              openFirewall = true;
              group = "multimedia";
              settings.server.port = cfg.ports.readarr;
            };
            sonarr = {
              enable = true;
              openFirewall = true;
              group = "multimedia";
              settings.server.port = cfg.ports.sonarr;
            };
          };

          system.stateVersion = "26.05";
        };
    };
  };
}
