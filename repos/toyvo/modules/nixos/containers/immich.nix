{
  config,
  lib,
  pkgs,
  homelab,
  ...
}:
let
  cfg = config.containerPresets.immich;
in
{
  options.containerPresets.immich = {
    enable = lib.mkEnableOption "Immich NixOS container";

    hostAddress = lib.mkOption {
      type = lib.types.str;
      default = "10.200.0.11";
      description = "Host side of the veth pair";
    };

    localAddress = lib.mkOption {
      type = lib.types.str;
      default = "10.200.0.12";
      description = "Container IP address";
    };

    natInterface = lib.mkOption {
      type = lib.types.str;
      description = "Host LAN-facing network interface for NAT masquerade (immich fetches metadata and ML models from external services)";
    };

    stateDir = lib.mkOption {
      type = lib.types.path;
      default = "/var/lib/nixos-containers/immich";
      description = "Base directory; subdirectories library/, postgresql/, and cache/ are bind-mounted into the container";
    };

    immichUid = lib.mkOption {
      type = lib.types.int;
      default = 354;
      description = "Pinned UID for the immich user (static, below 400 to avoid conflicts with NixOS dynamic system user allocation)";
    };

    package = lib.mkOption {
      type = lib.types.package;
      default = pkgs.immich;
      defaultText = lib.literalExpression "pkgs.immich";
      description = "Immich package";
    };

    ports = {
      immich = lib.mkOption {
        type = lib.types.port;
        default = homelab.immich.services.immich.port;
        description = "Immich web UI listen port";
      };
    };
  };

  config = lib.mkIf cfg.enable {
    networking.nat = {
      enable = true;
      externalInterface = cfg.natInterface;
      internalInterfaces = [ "ve-immich" ];
    };

    systemd.tmpfiles.rules = [
      "d /var/lib/nixos-containers/immich/var/log/journal 0755 root systemd-journal -"
    ];

    containers.immich = {
      autoStart = true;
      extraFlags = [ "--link-journal=guest" ];
      privateNetwork = true;
      hostAddress = cfg.hostAddress;
      localAddress = cfg.localAddress;

      bindMounts = {
        "/var/lib/immich" = {
          hostPath = "${cfg.stateDir}/library";
          isReadOnly = false;
        };
        "/var/lib/postgresql" = {
          hostPath = "${cfg.stateDir}/postgresql";
          isReadOnly = false;
        };
        "/var/cache/immich" = {
          hostPath = "${cfg.stateDir}/cache";
          isReadOnly = false;
        };
      };

      config =
        { ... }:
        {
          # Pin UID to match state dir ownership on the host
          users.users.immich = {
            uid = lib.mkForce cfg.immichUid;
            group = "immich";
            isSystemUser = true;
          };

          # Immich requires postgresql_16 with pgvecto-rs; the immich module
          # configures extensions and shared_preload_libraries automatically.
          services.postgresql.package = pkgs.postgresql_16;

          services.immich = {
            enable = true;
            host = "0.0.0.0";
            port = cfg.ports.immich;
            package = cfg.package;
            mediaLocation = "/var/lib/immich";
          };

          networking.firewall.allowedTCPPorts = [ cfg.ports.immich ];

          system.stateVersion = "26.05";
        };
    };
  };
}
