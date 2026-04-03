{
  config,
  lib,
  homelab,
  ...
}:
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

    bazarrUid = lib.mkOption {
      type = lib.types.int;
      default = 999;
      description = "Pinned UID for the bazarr user (must match state dir ownership on host)";
    };

    prowlarrUid = lib.mkOption {
      type = lib.types.int;
      default = 61654;
      description = "Pinned UID for the prowlarr user (must match state dir ownership on host; prowlarr uses DynamicUser upstream so this is required)";
    };

    readarrUid = lib.mkOption {
      type = lib.types.int;
      default = 997;
      description = "Pinned UID for the readarr user (must match state dir ownership on host)";
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
        "/mnt" = {
          hostPath = cfg.mediaDir;
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

          # Pin UIDs to match state dir ownership on the host.
          # bazarr and readarr are not in nixpkgs ids.nix so their UIDs can diverge
          # across systems. prowlarr uses DynamicUser=yes upstream and requires an
          # explicit static user.
          users.users.bazarr.uid = cfg.bazarrUid;
          users.users.readarr.uid = cfg.readarrUid;
          users.users.prowlarr = {
            uid = cfg.prowlarrUid;
            group = "prowlarr";
            isSystemUser = true;
          };
          users.groups.prowlarr = { };
          systemd.services.prowlarr.serviceConfig.DynamicUser = lib.mkForce false;

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
