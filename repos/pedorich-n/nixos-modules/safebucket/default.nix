{
  config,
  pkgs,
  lib,
  ...
}:
let
  cfg = config.services.safebucket;
in
{
  options = {
    services.safebucket = {
      enable = lib.mkEnableOption "safebucket";

      package = lib.mkPackageOption pkgs "safebucket" { };

      dataDir = lib.mkOption {
        type = lib.types.str;
        default = "/var/lib/safebucket";
        description = ''
          Path to store safebucket data.
          This path will be used for the following default environment variables:
          - DATABASE__SQLITE__PATH
          - ACTIVITY__FILESYSTEM__DIRECTORY
          - NOTIFIER__FILESYSTEM__DIRECTORY
        '';
      };

      openFirewall = lib.mkOption {
        type = lib.types.bool;
        default = false;
        description = "Whether to open the firewall for Safebucket.";
      };

      environment = lib.mkOption {
        type = lib.types.submodule {
          freeformType =
            with lib.types;
            attrsOf (oneOf [
              str
              int
              float
              bool
              path
              package
            ]);

          options = {
            APP__PORT = lib.mkOption {
              type = lib.types.port;
              default = 8080;
              description = "Port on which Safebucket listens.";
            };

            APP__STATIC_FILES__ENABLED = lib.mkOption {
              type = lib.types.bool;
              default = true;
              description = "Whether to enable static file serving.";
            };

            DATABASE__TYPE = lib.mkOption {
              type = lib.types.str;
              default = "sqlite";
              description = ''
                Database type which Safebucket will use.
                See <https://docs.safebucket.io/configuration/database-providers> for more information.
              '';
            };

            DATABASE__SQLITE__PATH = lib.mkOption {
              type = lib.types.nullOr lib.types.path;
              default = "${cfg.dataDir}/safebucket.db";
              description = "Path to the SQLite database for Safebucket to use.";
            };

            STORAGE__TYPE = lib.mkOption {
              type = lib.types.str;
              description = ''
                Storage provider to use with Safebucket.
                See <https://docs.safebucket.io/configuration/storage-providers> for more information.
              '';
            };

            CACHE__TYPE = lib.mkOption {
              type = lib.types.str;
              default = "memory";
              description = ''
                Cache to use with Safebucket.
                See <https://docs.safebucket.io/configuration/cache-providers> for more information.
              '';
            };

            ACTIVITY__TYPE = lib.mkOption {
              type = lib.types.str;
              default = "filesystem";
              description = ''
                Activity provider to use with Safebucket.
                See <https://docs.safebucket.io/configuration/activity-providers> for more information.
              '';
            };

            ACTIVITY__FILESYSTEM__DIRECTORY = lib.mkOption {
              type = lib.types.nullOr lib.types.path;
              default = "${cfg.dataDir}/activity";
              description = "Path to use for storing the Safebucket activity.";
            };

            NOTIFIER__TYPE = lib.mkOption {
              type = lib.types.str;
              default = "filesystem";
              description = ''
                Notifications provider to use with Safebucket.
                See <https://docs.safebucket.io/configuration/notification-providers> for more information.
              '';
            };

            NOTIFIER__FILESYSTEM__DIRECTORY = lib.mkOption {
              type = lib.types.nullOr lib.types.path;
              default = "${cfg.dataDir}/notifications";
              description = "Path to use for storing the Safebucket notifications.";
            };

            EVENTS__TYPE = lib.mkOption {
              type = lib.types.str;
              default = "memory";
              description = ''
                Events provider to use with Safebucket.
                See <https://docs.safebucket.io/configuration/event-providers> for more information.
              '';
            };

            EVENTS__QUEUES__NOTIFICATIONS__NAME = lib.mkOption {
              type = lib.types.str;
              default = "safebucket-notifications";
              description = "Notification events queue name.";
            };

            EVENTS__QUEUES__BUCKET_EVENTS__NAME = lib.mkOption {
              type = lib.types.str;
              default = "safebucket-bucket-events";
              description = "Storage bucket events queue name.";
            };

            EVENTS__QUEUES__OBJECT_DELETION__NAME = lib.mkOption {
              type = lib.types.str;
              default = "safebucket-object-deletion";
              description = "Object deletion events queue	name.";
            };

            AUTH__PROVIDERS__KEYS = lib.mkOption {
              type = lib.types.str;
              default = "local";
              description = ''
                Comma-separated list of auth providers to use with Safebucket.
                See <https://docs.safebucket.io/configuration/authentication> for more information.
              '';
            };
          };
        };

        default = { };
        description = ''
          Environment variables to set for the safebucket service.
          See <https://docs.safebucket.io/configuration/environment-variables> for more information.
        '';
      };

      environmentFiles = lib.mkOption {
        type = with lib.types; listOf path;
        default = [ ];
        example = [ "/run/secrets/safebucket.env" ];
        description = ''
          Files to load environment variables from in addition to [](#opt-services.safebucket.environment).
          This is useful to avoid putting secrets into the nix store.
          See <https://docs.safebucket.io/configuration/environment-variables> for more information.
        '';
      };
    };
  };

  config = lib.mkIf cfg.enable {
    systemd = {
      services.safebucket = {
        description = "Safebucket service";
        wantedBy = [ "multi-user.target" ];

        environment = lib.mapAttrs (_: val: if lib.isBool val then lib.boolToString val else toString val) cfg.environment;

        serviceConfig = {
          ExecStart = lib.getExe cfg.package;
          Restart = "on-failure";
          StateDirectory = "safebucket";
          StateDirectoryMode = "0750";
          EnvironmentFile = cfg.environmentFiles;

          ReadWritePaths = cfg.dataDir;

          # Hardening
          CapabilityBoundingSet = "";
          DynamicUser = true;
          LockPersonality = true;
          MemoryDenyWriteExecute = true;
          NoNewPrivileges = true;
          PrivateDevices = true;
          PrivateTmp = true;
          PrivateUsers = true;
          ProtectClock = true;
          ProtectControlGroups = true;
          ProtectHome = true;
          ProtectHostname = true;
          ProtectKernelLogs = true;
          ProtectKernelModules = true;
          ProtectKernelTunables = true;
          ProtectProc = "invisible";
          ProtectSystem = "strict";
          RemoveIPC = true;
          RestrictAddressFamilies = [
            "AF_INET"
            "AF_INET6"
            "AF_UNIX"
          ];
          RestrictNamespaces = true;
          RestrictRealtime = true;
          RestrictSUIDSGID = true;
          SystemCallArchitectures = "native";
          SystemCallFilter = [
            "@system-service"
            "@chown"
            "~@privileged"
          ];
          UMask = "0077"; # 600 for files, 700 for dirs
        };

        unitConfig.RequiresMountsFor = [ cfg.dataDir ];
      };

      tmpfiles.settings."10-safebucket" = {
        "${cfg.dataDir}".d = {
          user = "-";
          group = "-";
          argument = "0700";
        };
      };
    };

    networking.firewall = lib.mkIf cfg.openFirewall {
      allowedTCPPorts = [ cfg.environment.APP__PORT ];
    };
  };
}
