{
  config,
  lib,
  pkgs,
  inputs,
  ...
}:
let
  service = "lard";
  hl = config.homelab;
  cfg = hl.services.${service};
  port = 7477;
  package = inputs.lard.packages.${pkgs.stdenv.hostPlatform.system}.default;
  backupData = import ../../lib/backupData.nix { inherit lib; };
in
{
  options.homelab.services.${service} = {
    enable = lib.mkEnableOption "lard, a memory layer for homelab LLM sessions";

    host = lib.mkOption {
      type = lib.types.str;
      default = "127.0.0.1";
      description = "Tailscale IP/hostname where lard actually runs, if not this machine";
    };

    data = lib.mkOption {
      type = lib.types.nullOr backupData;
      default = {
        # dirOf sqlite backs up all of dataDir, which also covers the
        # memory/ and users/ subdirectories.
        sqlite = "${cfg.dataDir}/lard.db";
      };
      description = "What to back up for lard; see homelab/services/restic";
    };
    url = lib.mkOption {
      type = lib.types.str;
      default = "lard.${hl.baseDomainName}";
      description = "Domain to serve lard on";
    };
    dataDir = lib.mkOption {
      type = lib.types.path;
      default = "/var/lib/${service}";
      description = "Directory holding lard's sqlite db and memory subject files";
    };
    environmentFile = lib.mkOption {
      type = lib.types.nullOr lib.types.path;
      default = null;
      description = "EnvironmentFile containing LARD_HYPER_API_KEY, the key for the consolidation LLM";
    };
    multiUser = lib.mkEnableOption "give every authenticated indiko identity its own memory store";
    primaryUser = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      default = null;
      description = "indiko profile URL that owns requests carrying no OAuth identity; required when multiUser is enabled";
    };
    allowedUsers = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ ];
      description = "indiko profile URLs (\"me\") allowed to call lard; empty allows any authenticated indiko user";
    };
    glance.name = lib.mkOption {
      type = lib.types.str;
      default = "Lard";
    };
    glance.description = lib.mkOption {
      type = lib.types.str;
      default = "Memory layer for homelab LLM sessions";
    };
    glance.url = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      default = "https://${cfg.url}";
      description = "URL to show for this service in the Glance homelab bookmarks";
    };
  };

  config = lib.mkIf cfg.enable (
    lib.mkMerge [
      (lib.mkIf (cfg.host == "127.0.0.1") {
        assertions = [
          {
            assertion = cfg.multiUser -> cfg.primaryUser != null;
            message = "homelab.services.lard.primaryUser must be set when multiUser is enabled";
          }
        ];

        users.groups.${service} = { };
        users.users.${service} = {
          isSystemUser = true;
          group = service;
          home = cfg.dataDir;
          createHome = true;
        };

        systemd.tmpfiles.rules = [
          "d ${cfg.dataDir} 0750 ${service} ${service} -"
        ];

        systemd.services.${service} = {
          description = "lard memory layer";
          wantedBy = [ "multi-user.target" ];
          after = [ "network.target" ] ++ lib.optional hl.services.indiko.enable "indiko.service";

          environment = {
            LARD_ADDR = "127.0.0.1:${toString port}";
            LARD_DB = "${cfg.dataDir}/lard.db";
            LARD_MEMORY_DIR = "${cfg.dataDir}/memory";
            LARD_MULTI_USER = if cfg.multiUser then "true" else "false";
            LARD_DATA_DIR = "${cfg.dataDir}/users";
            LARD_AUTH = "oauth";
            LARD_AUTH_SERVER = "https://${hl.services.indiko.domain}";
            LARD_PUBLIC_URL = "https://${cfg.url}";
            # indiko auto-registers any URL as a public IndieAuth client; the
            # device grant lard-client uses needs no secret, so lard's own URL
            # doubles as its client id, matching indiko's IndieAuth pattern.
            LARD_OAUTH_CLIENT_IDS = "https://${cfg.url}";
            LARD_OAUTH_USERS = lib.concatStringsSep "," cfg.allowedUsers;
            LARD_COLLECTOR_CLIENT_ID = "https://${cfg.url}";
            LARD_COLLECTOR_SCOPES = "profile offline_access";
          }
          // lib.optionalAttrs (cfg.primaryUser != null) {
            LARD_PRIMARY_USER = cfg.primaryUser;
          };

          serviceConfig = {
            Type = "exec";
            User = service;
            Group = service;
            WorkingDirectory = cfg.dataDir;
            ExecStart = lib.getExe' package "lard";
            Restart = "on-failure";
            RestartSec = "10s";
            EnvironmentFile = lib.mkIf (cfg.environmentFile != null) cfg.environmentFile;

            NoNewPrivileges = true;
            ProtectSystem = "strict";
            ProtectHome = true;
            ReadWritePaths = [ cfg.dataDir ];
            PrivateTmp = true;
          };

          unitConfig.OnFailure = lib.mkIf (
            hl.notifications.ntfySecretsFile != null
          ) "notify-failure@%n.service";
        };
      })
      {
        services.caddy.virtualHosts.${cfg.url} = {
          useACMEHost = hl.baseDomainName;
          extraConfig = ''
            reverse_proxy http://${cfg.host}:${toString port}
          '';
        };
      }
    ]
  );
}
