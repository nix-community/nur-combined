{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.services.ghostfolio;

  inherit (lib)
    mkEnableOption
    mkIf
    mkOption
    optional
    types
    ;

  defaultDatabaseUrl = "postgresql://ghostfolio@localhost/ghostfolio?host=/run/postgresql";
in
{
  meta.maintainers = with lib.maintainers; [ moraxyc ];

  options.services.ghostfolio = {
    enable = mkEnableOption "Ghostfolio";

    package = lib.mkPackageOption pkgs "ghostfolio" { };

    host = mkOption {
      type = types.str;
      default = "::";
      description = "Host address Ghostfolio listens on.";
    };

    port = mkOption {
      type = types.port;
      default = 3333;
      description = "Port Ghostfolio listens on.";
    };

    rootUrl = mkOption {
      type = types.str;
      example = "https://wealth.example.com";
      description = "Public root URL of the Ghostfolio instance.";
    };

    logLevels = mkOption {
      type = types.listOf (
        types.enum [
          "debug"
          "error"
          "log"
          "verbose"
          "warn"
        ]
      );
      default = [ "warn" ];
      example = [
        "debug"
        "error"
        "log"
        "warn"
      ];
      description = "Ghostfolio log levels.";
    };

    autoMigrate = mkOption {
      type = types.bool;
      default = true;
      description = ''
        Whether to run Ghostfolio database migrations before starting the service.
      '';
    };

    environmentFile = mkOption {
      type = types.nullOr types.path;
      default = null;
      example = "/run/secrets/ghostfolio.env";
      description = ''
        Environment file containing secrets or additional variables.

        Common required variables include:

        - ACCESS_TOKEN_SALT
        - JWT_SECRET_KEY
      '';
    };

    settings = mkOption {
      type = types.attrsOf types.str;
      default = { };
      example = {
        REQUEST_TIMEOUT = "200";
      };
      description = ''
        Additional environment variables passed to Ghostfolio.

        See <https://github.com/ghostfolio/ghostfolio#supported-environment-variables> for available settings.
      '';
    };

    database = {
      createLocally = mkOption {
        type = types.bool;
        default = true;
        description = ''
          Whether to create a local PostgreSQL database and user for Ghostfolio.
        '';
      };

      url = mkOption {
        type = types.str;
        default = defaultDatabaseUrl;
        description = "PostgreSQL connection URL.";
      };
    };

    redis = {
      createLocally = mkOption {
        type = types.bool;
        default = true;
        description = ''
          Whether to create a local Redis instance for Ghostfolio.
        '';
      };

      host = mkOption {
        type = types.str;
        default = "localhost";
        description = "Redis host.";
      };

      port = mkOption {
        type = types.port;
        default = 6379;
        description = "Redis port.";
      };
    };
  };

  config = mkIf cfg.enable {
    assertions = [
      {
        assertion = cfg.environmentFile != null || cfg.settings ? JWT_SECRET_KEY;
        message = ''
          services.ghostfolio requires JWT_SECRET_KEY, usually via
          services.ghostfolio.environmentFile.
        '';
      }
      {
        assertion = cfg.environmentFile != null || cfg.settings ? ACCESS_TOKEN_SALT;
        message = ''
          services.ghostfolio requires ACCESS_TOKEN_SALT, usually via
          services.ghostfolio.environmentFile.
        '';
      }
      {
        assertion = cfg.database.createLocally -> cfg.database.url == defaultDatabaseUrl;
        message = ''
          services.ghostfolio.database.url should not be set when services.ghostfolio.database.createLocally is true.
        '';
      }
    ];

    services.postgresql = mkIf cfg.database.createLocally {
      enable = true;
      ensureDatabases = [ "ghostfolio" ];
      ensureUsers = [
        {
          name = "ghostfolio";
          ensureDBOwnership = true;
        }
      ];
    };

    services.redis.servers.ghostfolio = mkIf cfg.redis.createLocally {
      enable = true;
      bind = cfg.redis.host;
      port = cfg.redis.port;
    };

    systemd.services.ghostfolio = {
      description = "Ghostfolio";
      documentation = [ "https://ghostfol.io/" ];

      wantedBy = [ "multi-user.target" ];

      after = [
        "network-online.target"
      ]
      ++ optional cfg.database.createLocally "postgresql.service"
      ++ optional cfg.redis.createLocally "redis-ghostfolio.service";

      wants = [ "network-online.target" ];

      requires =
        optional cfg.database.createLocally "postgresql.service"
        ++ optional cfg.redis.createLocally "redis-ghostfolio.service";

      environment = {
        HOST = cfg.host;
        PORT = toString cfg.port;
        ROOT_URL = cfg.rootUrl;
        LOG_LEVELS = builtins.toJSON cfg.logLevels;

        DATABASE_URL = cfg.database.url;

        REDIS_HOST = cfg.redis.host;
        REDIS_PORT = toString cfg.redis.port;
      }
      // cfg.settings;

      serviceConfig =
        lib.optionalAttrs cfg.autoMigrate {
          ExecStartPre = lib.getExe' cfg.package "ghostfolio-migrate";
        }
        // {
          ExecStart = lib.getExe cfg.package;
          Type = "simple";

          Restart = "on-failure";
          RestartSec = "5s";

          DynamicUser = true;

          EnvironmentFile = optional (cfg.environmentFile != null) cfg.environmentFile;

          StateDirectory = "ghostfolio";
          CacheDirectory = "ghostfolio";
          RuntimeDirectory = "ghostfolio";

          # Hardening
          CapabilityBoundingSet = "";
          LockPersonality = true;
          MemoryDenyWriteExecute = false; # Required by V8 JIT
          NoNewPrivileges = true;
          PrivateDevices = true;
          PrivateTmp = true;
          PrivateUsers = true;
          ProtectControlGroups = true;
          ProtectHome = true;
          ProtectKernelLogs = true;
          ProtectKernelModules = true;
          ProtectKernelTunables = true;
          ProtectSystem = "strict";
          RestrictAddressFamilies = [
            "AF_UNIX"
            "AF_INET"
            "AF_INET6"
          ];
          RestrictNamespaces = true;
          RestrictRealtime = true;
          RestrictSUIDSGID = true;
          SystemCallArchitectures = "native";
          SystemCallFilter = [
            "@system-service"
            "~@privileged"
          ];
        };
    };
  };
}
