{
  config,
  lib,
  pkgs,
  homelab,
  ...
}:
let
  cfg = config.containerPresets.nextcloud;
in
{
  options.containerPresets.nextcloud = {
    enable = lib.mkEnableOption "Nextcloud + Collabora NixOS container";

    hostAddress = lib.mkOption {
      type = lib.types.str;
      default = "10.200.0.9";
      description = "Host side of the veth pair";
    };

    localAddress = lib.mkOption {
      type = lib.types.str;
      default = "10.200.0.10";
      description = "Container IP address";
    };

    natInterface = lib.mkOption {
      type = lib.types.str;
      description = "Host LAN-facing network interface for NAT masquerade (nextcloud reaches external mail/cloud services)";
    };

    stateDir = lib.mkOption {
      type = lib.types.path;
      default = "/var/lib/nixos-containers/nextcloud";
      description = "Base directory; subdirectories nextcloud/ and postgresql/ are bind-mounted into the container";
    };

    nextcloudAdminPasswordFile = lib.mkOption {
      type = lib.types.path;
      description = "Path to the Nextcloud admin password file on the host (decrypted by sops; bind-mounted read-only into the container)";
    };

    package = lib.mkOption {
      type = lib.types.package;
      default = pkgs.nextcloud33;
      defaultText = lib.literalExpression "pkgs.nextcloud33";
      description = "Nextcloud package version";
    };

    extraAppNames = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ ];
      description = "App names to enable from nextcloud's packages.apps (e.g. [ \"bookmarks\" \"calendar\" ])";
    };

    nextcloudUid = lib.mkOption {
      type = lib.types.int;
      default = 993;
      description = "Pinned UID for the nextcloud user (must match state dir ownership on host)";
    };

    nextcloudGid = lib.mkOption {
      type = lib.types.int;
      default = 991;
      description = "Pinned GID for the nextcloud group (must match state dir ownership on host)";
    };

    ports = {
      collabora = lib.mkOption {
        type = lib.types.port;
        default = homelab.nextcloud.services.collabora.port;
        description = "Collabora Online listen port";
      };
    };
  };

  config = lib.mkIf cfg.enable {
    networking.nat = {
      enable = true;
      externalInterface = cfg.natInterface;
      internalInterfaces = [ "ve-nextcloud" ];
    };

    containers.nextcloud = {
      autoStart = true;
      extraFlags = [ "--link-journal=host" ];
      privateNetwork = true;
      hostAddress = cfg.hostAddress;
      localAddress = cfg.localAddress;

      bindMounts = {
        # Admin password decrypted by sops on the host, made available read-only inside
        "/run/secrets/nextcloud_admin_password" = {
          hostPath = cfg.nextcloudAdminPasswordFile;
          isReadOnly = true;
        };
        "/var/lib/nextcloud" = {
          hostPath = "${cfg.stateDir}/nextcloud";
          isReadOnly = false;
        };
        # Nextcloud's bundled postgres — separate from the host's shared postgres instance
        "/var/lib/postgresql" = {
          hostPath = "${cfg.stateDir}/postgresql";
          isReadOnly = false;
        };
      };

      config =
        { config, ... }:
        {
          # Pin UIDs to match state dir ownership on the host
          users.users.nextcloud = {
            uid = lib.mkForce cfg.nextcloudUid;
            group = "nextcloud";
            isSystemUser = true;
          };
          users.groups.nextcloud.gid = lib.mkForce cfg.nextcloudGid;

          services.nextcloud = {
            enable = true;
            hostName = "nextcloud.diekvoss.net";
            package = cfg.package;
            config = {
              adminpassFile = "/run/secrets/nextcloud_admin_password";
              adminuser = "toyvo";
              dbtype = "pgsql";
              dbhost = "/run/postgresql";
            };
            settings.overwriteprotocol = "https";
            database.createLocally = true;
            extraApps = lib.genAttrs cfg.extraAppNames (
              name: config.services.nextcloud.package.packages.apps.${name}
            );
            extraAppsEnable = true;
          };

          # Pin postgres to version 16 — nextcloud's createLocally enables postgresql
          # and we match the major version used by the host's shared postgres instance.
          services.postgresql.package = pkgs.postgresql_16;

          services.collabora-online = {
            enable = true;
            port = cfg.ports.collabora;
            settings = {
              server_name = "collabora.diekvoss.net";
              storage.wopi = {
                "@allow" = true;
                # Collabora validates the WOPI file URL host against this list.
                # The token Nextcloud generates embeds the public hostname, so both
                # the internal localhost and the public domain must be allowed.
                host = [
                  "localhost"
                  "nextcloud\\.diekvoss\\.net"
                ];
              };
              net = {
                listen = "0.0.0.0";
                post_allow.host = [ "0.0.0.0" ];
              };
              ssl = {
                enable = false;
                termination = true;
              };
            };
          };

          # Configure the richdocuments app to point at the co-located collabora instance
          systemd.services.nextcloud-config-collabora =
            let
              inherit (config.services.nextcloud) occ;
              # Co-located: nextcloud PHP reaches collabora on localhost
              wopi_url = "http://localhost:${toString cfg.ports.collabora}";
              public_wopi_url = "https://collabora.diekvoss.net";
              # Collabora reaches Nextcloud's WOPI endpoint via the public domain, routing through
              # Caddy on the NAS host. Due to NAT hairpin, requests arrive as the router IP.
              # Allow localhost, the veth host address, the NAS LAN IP, and the router IP.
              wopi_allowlist = "127.0.0.1,${cfg.hostAddress},${homelab.nas.ip},${homelab.router.ip}";
            in
            {
              wantedBy = [ "multi-user.target" ];
              after = [
                "nextcloud-setup.service"
                "coolwsd.service"
              ];
              requires = [ "coolwsd.service" ];
              script = ''
                ${occ}/bin/nextcloud-occ config:app:set richdocuments wopi_url --value ${lib.escapeShellArg wopi_url}
                ${occ}/bin/nextcloud-occ config:app:set richdocuments public_wopi_url --value ${lib.escapeShellArg public_wopi_url}
                ${occ}/bin/nextcloud-occ config:app:set richdocuments wopi_allowlist --value ${lib.escapeShellArg wopi_allowlist}
                ${occ}/bin/nextcloud-occ richdocuments:setup
              '';
              serviceConfig.Type = "oneshot";
            };

          networking.firewall.allowedTCPPorts = [
            80 # nginx serving nextcloud
            cfg.ports.collabora
          ];

          system.stateVersion = "26.05";
        };
    };
  };
}
