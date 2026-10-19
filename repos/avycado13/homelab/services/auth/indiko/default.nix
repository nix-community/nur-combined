{
  config,
  lib,
  pkgs,
  ...
}:
let
  service = "indiko";
  hl = config.homelab;
  cfg = hl.services.${service};
  backupData = import ../../../lib/backupData.nix { inherit lib; };
in
{
  options.homelab.services.${service} = {
    enable = lib.mkEnableOption "Indiko authentication service";

    host = lib.mkOption {
      type = lib.types.str;
      default = "127.0.0.1";
      description = "Tailscale IP/hostname where indiko actually runs, if not this machine";
    };

    data = lib.mkOption {
      type = lib.types.nullOr backupData;
      default = {
        sqlite = "${cfg.dataDir}/data/indiko.db";
      };
      description = "What to back up for indiko; see homelab/services/restic";
    };

    domain = lib.mkOption {
      type = lib.types.str;
      default = "auth.${hl.baseDomainName}";
      description = "Domain to serve indiko on";
    };

    port = lib.mkOption {
      type = lib.types.port;
      default = 3000;
      description = "Port for indiko to listen on";
    };

    dataDir = lib.mkOption {
      type = lib.types.path;
      default = "/var/lib/${service}";
      description = "Directory to store indiko's app checkout and data";
    };

    repository = lib.mkOption {
      type = lib.types.str;
      description = "Git repository to deploy indiko from";
    };

    branch = lib.mkOption {
      type = lib.types.str;
      default = "main";
      description = "Git branch to deploy";
    };

    autoUpdate = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Git pull the latest revision of branch on every service restart";
    };

    secretsFile = lib.mkOption {
      type = lib.types.nullOr lib.types.path;
      default = null;
      description = "EnvironmentFile with indiko secrets";
    };

    glance.name = lib.mkOption {
      type = lib.types.str;
      default = "Auth";
    };
    glance.url = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      default = "https://${cfg.domain}";
      description = "URL to show for this service in the Glance homelab bookmarks";
    };
  };

  config = lib.mkIf cfg.enable (
    lib.mkMerge [
      (lib.mkIf (cfg.host == "127.0.0.1") {
        users.groups.${service} = { };
        users.users.${service} = {
          isSystemUser = true;
          group = service;
          home = cfg.dataDir;
          createHome = true;
        };

        systemd.tmpfiles.rules = [
          "d ${cfg.dataDir} 0755 ${service} ${service} -"
          "d ${cfg.dataDir}/data 0755 ${service} ${service} -"
        ];

        systemd.services.${service} = {
          description = "Indiko authentication service";
          wantedBy = [ "multi-user.target" ];
          after = [ "network.target" ];
          path = [
            pkgs.bun
            pkgs.git
          ];

          preStart = ''
            set -e
            for f in indiko.db indiko.db-wal indiko.db-shm; do
              if [ -e ${cfg.dataDir}/app/data/$f ] && [ ! -e ${cfg.dataDir}/data/$f ]; then
                mv ${cfg.dataDir}/app/data/$f ${cfg.dataDir}/data/$f
              fi
            done
            if [ -d ${cfg.dataDir}/app/.git ] && [ "$(${pkgs.git}/bin/git -C ${cfg.dataDir}/app remote get-url origin)" != "${cfg.repository}" ]; then
              rm -rf ${cfg.dataDir}/app
            fi
            if [ ! -d ${cfg.dataDir}/app/.git ]; then
              ${pkgs.git}/bin/git clone -b ${cfg.branch} ${cfg.repository} ${cfg.dataDir}/app
            fi
            cd ${cfg.dataDir}/app
            ${lib.optionalString cfg.autoUpdate ''
              ${pkgs.git}/bin/git fetch origin
              ${pkgs.git}/bin/git reset --hard origin/${cfg.branch}
            ''}
            ${pkgs.bun}/bin/bun install
          '';

          script = ''
            cd ${cfg.dataDir}/app
            exec ${pkgs.bun}/bin/bun run start
          '';

          serviceConfig = {
            Type = "exec";
            User = service;
            Group = service;
            WorkingDirectory = cfg.dataDir;
            Restart = "on-failure";
            RestartSec = "10s";
            TimeoutStartSec = "120s";
            EnvironmentFile = lib.mkIf (cfg.secretsFile != null) cfg.secretsFile;
            Environment = [
              "ORIGIN=https://${cfg.domain}"
              "RP_ID=${cfg.domain}"
              "PORT=${toString cfg.port}"
              "NODE_ENV=production"
              "DATABASE_URL=${cfg.dataDir}/data/indiko.db"
              "COOKIE_DOMAIN=.${hl.baseDomainName}"
            ];

            NoNewPrivileges = true;
            ProtectSystem = "strict";
            ProtectHome = true;
            ReadWritePaths = [ cfg.dataDir ];
            PrivateTmp = true;
          };
        };
      })
      {
        services.caddy.virtualHosts.${cfg.domain} = {
          extraConfig = ''
            reverse_proxy ${cfg.host}:${toString cfg.port}
             header {
            X-Frame-Options "DENY"
            X-Content-Type-Options "nosniff"
            X-XSS-Protection "1; mode=block"
            Referrer-Policy "strict-origin-when-cross-origin"
            Permissions-Policy "geolocation=(), microphone=(), camera=()"
            Strict-Transport-Security "max-age=31536000; includeSubDomains; preload"
            }
          '';
        };
      }
    ]
  );
}
