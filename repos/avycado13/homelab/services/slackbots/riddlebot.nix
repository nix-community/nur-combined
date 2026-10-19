{
  config,
  lib,
  pkgs,
  ...
}:
let
  service = "riddlebot";
  hl = config.homelab;
  cfg = hl.services.slackbots.${service};
in
{
  options.homelab.services.slackbots.${service} = {
    enable = lib.mkEnableOption "RiddleBot slackbot";

    host = lib.mkOption {
      type = lib.types.str;
      default = "127.0.0.1";
      description = "Tailscale IP/hostname where RiddleBot actually runs, if not this machine";
    };
    dataDir = lib.mkOption {
      type = lib.types.path;
      default = "/var/lib/${service}";
      description = "Directory to store RiddleBot's app checkout and data";
    };
    repository = lib.mkOption {
      type = lib.types.str;
      default = "https://github.com/avycado13/riddlebot.git";
      description = "Git repository to deploy RiddleBot from";
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
      description = "EnvironmentFile with RiddleBot secrets";
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
          description = "RiddleBot Slackbot";
          wantedBy = [ "multi-user.target" ];
          after = [ "network.target" ];
          path = [
            pkgs.nodejs
            pkgs.git
            pkgs.pnpm
          ];

          preStart = ''
            set -e
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
            ${pkgs.pnpm}/bin/pnpm install --frozen-lockfile
          '';

          script = ''
            cd ${cfg.dataDir}/app
            exec ${pkgs.nodejs}/bin/node index.ts
          '';

          serviceConfig = {
            Type = "exec";
            User = service;
            Group = service;
            WorkingDirectory = cfg.dataDir;
            Restart = "on-failure";
            RestartSec = "10s";
            TimeoutStartSec = "120s";

            NoNewPrivileges = true;
            ProtectSystem = "strict";
            ProtectHome = true;
            ReadWritePaths = [ cfg.dataDir ];
            PrivateTmp = true;
          }
          // lib.optionalAttrs (cfg.secretsFile != null) {
            EnvironmentFile = cfg.secretsFile;
          };
        };
      })
    ]
  );
}
