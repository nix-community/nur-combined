{
  config,
  lib,
  pkgs,
  ...
}:
let
  service = "irc";
  hl = config.homelab;
  cfg = hl.services.${service};
  certDir = config.security.acme.certs.${hl.baseDomainName}.directory;
  backupData = import ../../lib/backupData.nix { inherit lib; };
in
{
  options.homelab.services.${service} = {
    enable = lib.mkEnableOption "Enable soju IRC bouncer and eventually gamja";

    host = lib.mkOption {
      type = lib.types.str;
      default = "127.0.0.1";
      description = "Tailscale IP/hostname where soju actually runs, if not this machine";
    };

    data = lib.mkOption {
      type = lib.types.nullOr backupData;
      default = {
        # soju's actual unit is "soju", not "irc" (the homelab.services key).
        # Stopped rather than sqlite-checkpointed since soju's db layout
        # isn't guaranteed to be a single top-level sqlite file.
        files = [ "/var/lib/soju" ];
        stopUnits = [ "soju" ];
        stopForBackup = true;
      };
      description = "What to back up for irc/soju; see homelab/services/restic";
    };
    url = lib.mkOption {
      type = lib.types.str;
      default = "irc.${hl.baseDomainName}";
      description = "Hostname soju identifies as and serves TLS for";
    };
    port = lib.mkOption {
      type = lib.types.port;
      default = 3030;
      description = "Port soju listens on for gamja and websocket connections";
    };
    ircsPort = lib.mkOption {
      type = lib.types.port;
      default = 6697;
      description = "Port soju listens on for IRC-over-TLS connections";
    };
    glance.name = lib.mkOption {
      type = lib.types.str;
      default = "Soju";
    };
    glance.url = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      default = cfg.url;
      description = "Gamja web ui";
    };
  };

  config = lib.mkIf cfg.enable (
    lib.mkMerge [
      (lib.mkIf (cfg.host == "127.0.0.1") {
        services.soju = {
          enable = true;
          hostName = cfg.url;
          listen = [
            "ircs://:${toString cfg.ircsPort}"
            "ws+insecure://:${toString cfg.port}"
          ];
          tlsCertificate = "${certDir}/fullchain.pem";
          tlsCertificateKey = "${certDir}/key.pem";
        };

        # soju runs with a static user (not DynamicUser) so it can be added to
        # the ACME cert group and read the shared wildcard cert/key.
        users.users.soju = {
          isSystemUser = true;
          group = "soju";
          extraGroups = [ config.services.caddy.group ];
        };
        users.groups.soju = { };
        systemd.services.soju.serviceConfig = {
          DynamicUser = lib.mkForce false;
          User = "soju";
          Group = "soju";
        };

        security.acme.certs.${hl.baseDomainName}.reloadServices = [ "soju.service" ];

        networking.firewall.allowedTCPPorts = [ cfg.port ];

        systemd.services.soju.serviceConfig.OnFailure = lib.mkIf (
          hl.notifications.ntfySecretsFile != null
        ) "notify-failure@%n.service";
      })
      {
        services.caddy.virtualHosts."${cfg.url}" = {
          useACMEHost = hl.baseDomainName;
          extraConfig = ''
            root * ${pkgs.compressDrvWeb pkgs.gamja { }}
            file_server browse {
                precompressed br gzip
            }
            @soju {
                path /socket
                path /uploads
                path /uploads/*
            }
            reverse_proxy @soju http://${cfg.host}:${toString cfg.port}
          '';
        };
      }
    ]
  );
}
