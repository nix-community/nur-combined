{
  config,
  lib,
  homelab,
  ...
}:
let
  cfg = config.containerPresets.jellyfin;
in
{
  options.containerPresets.jellyfin = {
    enable = lib.mkEnableOption "Jellyfin NixOS container";

    hostAddress = lib.mkOption {
      type = lib.types.str;
      default = "10.200.0.5";
      description = "Host side of the veth pair";
    };

    localAddress = lib.mkOption {
      type = lib.types.str;
      default = "10.200.0.6";
      description = "Container IP address";
    };

    natInterface = lib.mkOption {
      type = lib.types.str;
      description = "Host LAN-facing network interface for NAT masquerade (jellyfin fetches metadata from external services)";
    };

    stateDir = lib.mkOption {
      type = lib.types.path;
      default = "/var/lib/nixos-containers/jellyfin";
      description = "Directory bind-mounted into the container at /var/lib/jellyfin";
    };

    mediaDir = lib.mkOption {
      type = lib.types.path;
      description = "Media pool path bind-mounted read-only into the container at /mnt";
    };

    multimediaGid = lib.mkOption {
      type = lib.types.int;
      default = 349;
      description = "Pinned GID for the multimedia group on both host and container";
    };

    jellyfinUid = lib.mkOption {
      type = lib.types.int;
      default = 989;
      description = "Pinned UID for the jellyfin user (must match state dir ownership on host)";
    };

    videoGid = lib.mkOption {
      type = lib.types.int;
      default = 26;
      description = "Pinned GID for the video group (must match host; required for /dev/dri/card1 access)";
    };

    renderGid = lib.mkOption {
      type = lib.types.int;
      default = 303;
      description = "Pinned GID for the render group (must match host; required for /dev/dri/renderD128 access)";
    };

    ports = {
      jellyfin = lib.mkOption {
        type = lib.types.port;
        default = homelab.jellyfin.services.jellyfin.port;
        description = "Jellyfin web UI listen port";
      };
    };
  };

  config = lib.mkIf cfg.enable {
    services.monitoring.containerJournals = [ "jellyfin" ];
    # Pin multimedia GID so bind-mounted media paths are accessible from inside the container
    users.groups.multimedia.gid = cfg.multimediaGid;

    # NAT masquerade so jellyfin can reach external metadata providers
    networking.nat = {
      enable = true;
      externalInterface = cfg.natInterface;
      internalInterfaces = [ "ve-jellyfin" ];
    };

    systemd.tmpfiles.rules = [
      "d /var/lib/nixos-containers/jellyfin/var/log/journal 0755 root systemd-journal -"
    ];

    containers.jellyfin = {
      autoStart = true;
      extraFlags = [ "--link-journal=guest" ];
      privateNetwork = true;
      hostAddress = cfg.hostAddress;
      localAddress = cfg.localAddress;

      # DRI device nodes for GPU-accelerated transcoding
      allowedDevices = [
        {
          node = "/dev/dri/renderD128";
          modifier = "rwm";
        }
        {
          node = "/dev/dri/card1";
          modifier = "rwm";
        }
      ];

      bindMounts = {
        "/dev/dri" = {
          hostPath = "/dev/dri";
          isReadOnly = false;
        };
        "/var/lib/jellyfin" = {
          hostPath = cfg.stateDir;
          isReadOnly = false;
        };
        # Media is read-only; writes (thumbnails, etc.) go to /var/lib/jellyfin
        "/mnt" = {
          hostPath = cfg.mediaDir;
          isReadOnly = true;
        };
      };

      config =
        { ... }:
        {
          # Must match host GID so bind-mounted media paths are readable
          users.groups.multimedia = {
            gid = cfg.multimediaGid;
          };

          # Match host GIDs so DRI device node permissions work inside the container
          users.groups.video.gid = cfg.videoGid;
          users.groups.render.gid = cfg.renderGid;

          # Pin UID to match state dir ownership on the host. sysusers only creates absent
          # users so a pre-existing dir with a different UID will not be chowned automatically.
          users.users.jellyfin = {
            uid = lib.mkForce cfg.jellyfinUid;
            group = "multimedia";
            extraGroups = [
              "video"
              "render"
            ];
            isSystemUser = true;
          };

          services.jellyfin = {
            enable = true;
            openFirewall = true;
            group = "multimedia";
          };

          networking.firewall.allowedTCPPorts = [ cfg.ports.jellyfin ];

          system.stateVersion = "26.05";
        };
    };
  };
}
